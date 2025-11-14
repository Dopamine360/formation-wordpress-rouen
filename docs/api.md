# Spécification API Backend

Base URL : `https://api.vote.example.com/v1`

## Authentification
- Toutes les routes (sauf `/auth/login`, `/auth/verify-otp`) nécessitent un header `Authorization: Bearer <JWT>`.
- Signature additionnelle : header `X-Signature` (Ed25519) et `X-Timestamp`.

## Endpoints

### POST `/auth/login`
- **Description** : Démarre la procédure d'authentification votant.
- **Body** :
```json
{
  "email": "voter@example.com",
  "referendum_id": "uuid",
  "client_nonce": "base64",
  "signature": "base64"
}
```
- **Réponses** :
  - `200 OK`
```json
{
  "challenge_id": "uuid",
  "otp_channel": "email",
  "expires_in": 300
}
```
  - `400` / `401` en cas d'erreur.

### POST `/auth/verify-otp`
- **Description** : Vérifie l'OTP et délivre les tokens.
- **Body** :
```json
{
  "challenge_id": "uuid",
  "otp_code": "123456",
  "device_info": {"platform": "ios", "version": "17.0"}
}
```
- **Réponse 200** :
```json
{
  "access_token": "jwt",
  "refresh_token": "jwt",
  "expires_in": 900,
  "refresh_expires_in": 1209600,
  "requires_mfa": false
}
```

### POST `/votants/register`
- **Description** : Enrôle un votant (admin ou batch import).
- **Auth** : JWT administrateur.
- **Body** :
```json
{
  "referendum_id": "uuid",
  "email": "voter@example.com",
  "display_name": "",
  "public_signing_key": "base64",
  "eligibility_token": "base64",
  "otp_delivery": "email"
}
```
- **Réponse 201** :
```json
{
  "voter_id": "uuid",
  "temporary_password": null,
  "invitation_sent": true
}
```

### POST `/referendum/create`
- **Description** : Crée un nouveau référendum.
- **Auth** : JWT administrateur + rôle `election_admin`.
- **Body** :
```json
{
  "title": "Référendum A",
  "description": "Markdown",
  "start_at": "2024-10-10T08:00:00Z",
  "end_at": "2024-10-12T20:00:00Z",
  "options": [
    {"label": "Oui"},
    {"label": "Non"}
  ],
  "result_mode": "hidden_until_close"
}
```
- **Réponse 201** :
```json
{
  "referendum_id": "uuid",
  "public_key": "base64",
  "status": "draft"
}
```

### POST `/vote/submit`
- **Description** : Soumission d'un bulletin chiffré.
- **Body** :
```json
{
  "referendum_id": "uuid",
  "ballot_ciphertext": {
    "c1": "base64",
    "c2": "base64"
  },
  "proof_commitment": "base64",
  "merkle_leaf": "base64",
  "client_timestamp": "2024-10-10T09:00:00Z",
  "nonce": "base64",
  "signature": "base64"
}
```
- **Réponse 202** :
```json
{
  "vote_id": "uuid",
  "merkle_root": "base64",
  "merkle_path": ["base64", "base64"],
  "server_timestamp": "2024-10-10T09:00:01Z",
  "receipt_signature": "base64"
}
```

### GET `/vote/verify`
- **Description** : Vérifie si un bulletin est comptabilisé.
- **Query** : `vote_id`, `merkle_root` ou `voter_pseudonym`.
- **Réponse 200** :
```json
{
  "vote_id": "uuid",
  "status": "counted",
  "merkle_root": "base64",
  "merkle_path": ["base64"],
  "audit_log_reference": "uuid",
  "server_signature": "base64"
}
```

## Codes d'erreur génériques
- `401` : non authentifié / OTP invalide.
- `403` : accès refusé, hors période.
- `409` : vote déjà soumis.
- `422` : preuve cryptographique invalide.
- `429` : rate limit.

## Sécurité API
- Toutes les routes derrière TLS 1.3, cipher suites modernes.
- Vérification `X-Timestamp` ± 30s.
- Rejeu bloqué via Redis (nonce).
- Audit log à chaque réponse critique.
