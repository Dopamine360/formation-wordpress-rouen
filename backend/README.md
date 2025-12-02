# Service de vote référendum (Node.js/TypeScript)

## Variables d'environnement
- `DATABASE_URL` : URL Postgres
- `ADMIN_API_KEY` : clé API pour les routes /admin
- `JWT_SECRET` : secret JWT utilisateurs
- `PORT` : port HTTP

## Démarrage
```
npm install
npm run build
npm start
```

## Endpoints
- `POST /admin/referendums` (clé API): crée un référendum + options.
- `GET /referendums`: liste des référendums ouverts.
- `GET /referendums/:id`: détail d'un référendum.
- `POST /votes` (JWT utilisateur): enregistre un vote (idempotent si déjà voté).
- `GET /results/:referendum_id` (JWT): totaux par option.
- `GET /me/votes` (JWT): renvoie les votes de l'utilisateur.

## Schéma des flux (texte)
WP utilisateur ↔ (HTTPS/JWT) ↔ API Node ↔ PostgreSQL
WP admin ↔ (HTTPS/API Key) ↔ API Node ↔ PostgreSQL
Mobile React Native ↔ (HTTPS/JWT) ↔ API Node ↔ PostgreSQL

## Sécurité / anonymat
- Unicité de vote : contrainte UNIQUE(wp_user_id, referendum_id) dans `user_votes` + contrôle applicatif.
- Anonymat : choix stocké dans `votes` via `vote_token`; `user_votes` ne contient pas `choice_id`.
- Tableau de bord : jointure contrôlée via `link_token`/`vote_token` pour ne restituer qu'à l'utilisateur.
- API sécurisée par clé API (admin) et JWT (utilisateur). Toutes les requêtes doivent passer en HTTPS.
