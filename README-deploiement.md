# Déploiement de l'écosystème CivicVote

## Vue d'ensemble
Cette pile se compose de :
- WordPress headless (WPGraphQL) pour le front public.
- API FastAPI (`backend/`) pour la gestion des référendums et votes.
- Base PostgreSQL + Redis.
- Application Flutter (`mobile/`) distribuée via stores ou en sideload.

## Prérequis
- Docker & Docker Compose v2
- Domaine avec certificat TLS (Let's Encrypt via Traefik)
- Accès à un HSM/KMS pour les clés de chiffrement (AWS KMS, HashiCorp Vault ou équivalent)
- Stockage objet (S3 ou compatible) pour journaux Merkle et archives

## Structure des conteneurs
```yaml
services:
  traefik: reverse proxy + TLS + ACME
  wordpress: image wordpress officielle, WPGraphQL activé
  civicvote-api: image construite depuis `backend/`
  postgres: base de données principale
  redis: cache + OTP
  merkle-worker: job périodique pour calcul racine Merkle
```

## Exemple `docker-compose.yml`
```yaml
version: '3.9'
services:
  traefik:
    image: traefik:v3.0
    command:
      - '--entrypoints.websecure.address=:443'
      - '--providers.docker=true'
      - '--certificatesresolvers.le.acme.email=admin@example.com'
      - '--certificatesresolvers.le.acme.storage=/acme.json'
      - '--certificatesresolvers.le.acme.tlschallenge=true'
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - '/var/run/docker.sock:/var/run/docker.sock:ro'
      - './data/traefik/acme.json:/acme.json'
    restart: unless-stopped

  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: civicvote
      POSTGRES_USER: civicvote
      POSTGRES_PASSWORD: change-me
    volumes:
      - ./data/postgres:/var/lib/postgresql/data
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    command: ['redis-server', '--appendonly', 'yes']
    volumes:
      - ./data/redis:/data
    restart: unless-stopped

  civicvote-api:
    build:
      context: ./backend
    environment:
      DATABASE_URL: postgresql+asyncpg://civicvote:change-me@postgres:5432/civicvote
      REDIS_URL: redis://redis:6379/0
      JWT_SECRET: super-secret
      ENVIRONMENT: production
    depends_on:
      - postgres
      - redis
    labels:
      - 'traefik.enable=true'
      - 'traefik.http.routers.civicvote.rule=Host(`api.vote.example.com`)' 
      - 'traefik.http.routers.civicvote.entrypoints=websecure'
      - 'traefik.http.routers.civicvote.tls.certresolver=le'
    restart: unless-stopped

  wordpress:
    image: wordpress:6-php8.2-fpm
    environment:
      WORDPRESS_DB_HOST: postgres
      WORDPRESS_DB_NAME: civicvote_wp
      WORDPRESS_DB_USER: civicvote
      WORDPRESS_DB_PASSWORD: change-me
    depends_on:
      - postgres
    volumes:
      - ./wordpress:/var/www/html
    restart: unless-stopped

  wordpress-nginx:
    image: nginx:1.25-alpine
    volumes:
      - ./wordpress:/var/www/html:ro
      - ./ops/nginx/wordpress.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - wordpress
    labels:
      - 'traefik.enable=true'
      - 'traefik.http.routers.wp.rule=Host(`vote.example.com`)' 
      - 'traefik.http.routers.wp.entrypoints=websecure'
      - 'traefik.http.routers.wp.tls.certresolver=le'
    restart: unless-stopped
```

## Construction des images
```bash
# Backend
cd backend
pip install build
python -m build
# ou directement
docker build -t civicvote-api:latest .

# Application Flutter (APK)
cd mobile
flutter build apk --dart-define=API_BASE_URL=https://api.vote.example.com/v1
```

## Sécurité & bonnes pratiques
- Activer mTLS entre Traefik et l'API (certificats internes).
- Stocker secrets (JWT_SECRET, clés OTP) dans un secret manager (Vault, AWS Secrets Manager).
- Désactiver l'inscription publique WordPress et limiter les comptes administrateurs.
- Mettre en place un WAF (Cloudflare) et rate limiting.
- Surveiller les logs : exporter vers SIEM, alertes sur anomalies d'OTP.
- Sauvegarde régulière PostgreSQL (pg_dump) + rotation quotidienne.
- Ancrer la racine Merkle quotidienne sur une blockchain publique (ex: Ethereum via contrat léger) ou un service TSA.
- Tests d'intrusion réguliers, revues de code cryptographique.

## Déploiement automatisé
- Utiliser GitHub Actions / GitLab CI :
  - Lint + tests unitaires backend/mobile.
  - Scan SAST (Bandit, SonarQube) et SCA (Dependabot).
  - Build images Docker et push vers registre privé.
  - Déploiement via SSH ou orchestrateur (Kubernetes) avec Helm charts.

## Surveillance
- Prometheus + Grafana pour métriques API et base de données.
- Alerting sur taux d'erreurs OTP, latence vote.
- Export logs Traefik + API vers Loki/ELK.

## Mise à jour de la clé de scrutin
- Générer nouvelle paire pour chaque référendum.
- Distribuer clé publique via API signée.
- Après dépouillement, archiver clés privées partagées et révoquer accès.

## Plan de reprise
- Backups chiffrés hors site (S3 + versioning).
- Procédure documentée pour restaurer base et preuves Merkle.
- Tests réguliers de restauration (au moins trimestriels).
