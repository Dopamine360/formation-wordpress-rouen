# Système de référendum en ligne (France)

## Choix mobile
React Native retenu : large écosystème JS partagé avec le backend/WordPress et support iOS/Android rapide.

## Flux (texte)
- Utilisateur web : WordPress → (JWT via plugin) → API Node → PostgreSQL
- Admin web : WordPress (page admin) → (clé API) → API Node → PostgreSQL
- Mobile : React Native → (JWT) → API Node → PostgreSQL
- Vérification e-mail : WP envoie un lien /?verify_email=... avant tout vote/consultation résultats.

## Étapes clés côté WordPress
1. Inscription → email_verified=0 + envoi lien de confirmation.
2. Lien de validation met email_verified=1.
3. Shortcode `[referendums_vote]` : affiche les référendums ouverts, bloque si non vérifié, envoie les votes via AJAX au service Node.
4. Page admin : création de référendum en appelant l'API `/admin/referendums`.

## API (résumé)
Voir `backend/README.md` pour le détail des routes. JWT obligatoire pour voir résultats ou voter; clé API pour la partie admin.

## Mobile
`mobile/App.tsx` fournit un squelette : login (proxy WP), liste des référendums, vote et page "Mes votes" consommant l'API REST.

## SQL
`backend/sql/schema.sql` prêt à exécuter pour PostgreSQL avec anonymisation (votes séparés de la table user_votes).
