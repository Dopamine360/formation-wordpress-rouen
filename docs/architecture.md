# Architecture du système de vote citoyen

```mermaid
graph TD
    subgraph Frontend
        WP[WordPress Headless]
        Mobile[App mobile Flutter]
    end

    subgraph Auth[Service Auth & Identity]
        OTP[Service OTP]
        JWT[Gestion JWT/Refresh]
        MFA[2FA - TOTP/Push]
    end

    subgraph VoteBackend[API de vote (FastAPI)]
        Gateway[API Gateway REST]
        RefSvc[Service Référendums]
        VoterSvc[Service Votants]
        BallotSvc[Service Bulletins]
        ProofSvc[Service Preuves]
        AuditSvc[Service Journal immuable]
    end

    subgraph Data[Stockage]
        WPDB[(Base WordPress)]
        VoteDB[(Base relationnelle Votes)]
        ProofStore[(Stockage Preuves & Merkle)]
        Secrets[(HSM/Service KMS)]
        Cache[(Redis/Memory Cache)]
    end

    subgraph Observability
        Logs[Centralisation logs]
        Metrics[Metrics & alerting]
        SIEM[SIEM]
    end

    WP -->|REST/GraphQL| Gateway
    Mobile -->|REST/GraphQL| Gateway
    Gateway --> RefSvc
    Gateway --> VoterSvc
    Gateway --> BallotSvc
    Gateway --> ProofSvc
    Gateway --> AuditSvc

    VoterSvc --> Auth
    Auth --> OTP
    Auth --> JWT
    Auth --> MFA

    RefSvc --> VoteDB
    VoterSvc --> VoteDB
    BallotSvc --> VoteDB
    ProofSvc --> ProofStore
    AuditSvc --> ProofStore
    AuditSvc --> SIEM

    Gateway --> Cache
    Gateway --> Logs
    Logs --> Metrics
```

## Description des composants

### WordPress (Headless)
- Utilise WPGraphQL pour exposer contenu éditorial et informations publiques.
- Tableau de bord votant intégré via Next.js/React consommant l'API de vote.
- Authentification WordPress distincte des votants.

### Application mobile Flutter
- Consomme l'API de vote via HTTPS.
- Stocke localement clés publiques des élections et preuves personnelles.
- Chiffrement côté client (module Dart pour ElGamal sur courbe elliptique).

### API de vote (FastAPI)
- Architecture micro-services modulaires dans un même projet : routers séparés.
- Gestion JWT + refresh + OTP via TOTP (RFC 6238) ou email OTP.
- Rate limiting via API Gateway (Traefik/NGINX) et Redis.

### Stockage
- Base relationnelle (PostgreSQL) pour référendums, électeurs, bulletins chiffrés, états d'auth.
- Stockage append-only (S3 + Merkle tree) pour preuves et journaux.
- KMS/HSM pour gestion clés maître (déchiffrement partielles si recensement).

### Sécurité & Observabilité
- mTLS entre services internes.
- Signatures requêtes côté client (clé privée votant) + horodatage serveur.
- Journal immuable alimenté par chaque événement critique.
- Intégration SIEM pour surveillance.

## Flux principal de vote

1. **Provisionnement référendum** : administrateur via WordPress admin ou back-office séparé appelle `/referendum/create` avec métadonnées. L'API génère une clé publique spécifique au scrutin et la publie.
2. **Enrôlement votant** : import CSV ou création via `/votants/register`. Chaque votant reçoit un identifiant, un secret OTP et une paire de clés éphémère (publique enregistrée, privée stockée uniquement côté votant).
3. **Authentification** : votant se connecte (`/auth/login`) avec email + OTP. Serveur renvoie JWT + refresh après vérification.
4. **Vote** : le client télécharge la clé publique du scrutin, chiffre le bulletin via schéma ElGamal homomorphe et signe la requête. Le serveur valide, stocke le bulletin chiffré et ajoute un hash dans l'arbre de Merkle.
5. **Preuve** : serveur retourne un identifiant de preuve (chemin de Merkle + commit). Le client peut vérifier via `/vote/verify` en récupérant chemin et recalculant la racine.
6. **Décompte** : à la clôture, le service de dépouillement effectue un déchiffrement homomorphe (avec partage de clés entre autorités) et publie les résultats signés.

## Choix technologiques

- **FastAPI** pour rapidité de développement, typage Python, intégration aisée de bibliothèques cryptographiques (PyNaCl, Python-ElGamal) et async.
- **Flutter** pour cible mobile multiplateforme avec un seul code base, support Web éventuel.
- **PostgreSQL** pour fiabilité, JSONB pour stocker preuves.
- **Redis** pour gestion sessions OTP et rate limiting.
- **Traefik** comme reverse proxy (Let's Encrypt) et en-têtes de sécurité.

## Gestion du journal immuable
- Chaque événement (enrôlement, authentification, vote, validation) génère un enregistrement immuable (hash SHA-256).
- Les enregistrements sont insérés dans un arbre de Merkle périodique; la racine est ancrée sur une blockchain publique ou service d'horodatage qualifié.
- Les preuves de Merkle sont stockées et accessibles via `/vote/verify`.

## Interactions WordPress ↔ API
- WordPress consomme `/referendum/*` pour lister scrutins sur le site public.
- Tableau de bord votant (React) utilise `/auth/*` et `/vote/*`.
- Webhooks depuis API vers WordPress pour mettre à jour statut des scrutins.

## Séparation des données
- Les données personnelles (identifiants, OTP) sont séparées du bulletin chiffré.
- Les votes ne contiennent aucun identifiant direct, uniquement un pseudonyme dérivé (hash du token d'éligibilité).

## Gestion des clés
- Autorité électorale détient clé maîtresse partagée via schéma de Shamir (m out of n) pour déchiffrement final.
- Chaque votant génère une paire de clés pour signer sa requête et reçoit la clé publique du scrutin pour chiffrer.
```
