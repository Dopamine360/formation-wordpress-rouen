# Modèle de données

## Vue d'ensemble
- **Schéma `core`** : métadonnées (référendums, options, électeurs).
- **Schéma `ballots`** : bulletins chiffrés et preuves.
- **Schéma `audit`** : journaux immuables.

## Tables principales

### `core.referendums`
| Colonne | Type | Description |
| --- | --- | --- |
| `id` | UUID PK | Identifiant unique du scrutin |
| `title` | TEXT | Titre affiché |
| `description` | TEXT | Description longue (Markdown) |
| `status` | ENUM(draft, published, ongoing, closed, archived) | Statut |
| `start_at` | TIMESTAMPTZ | Date/heure d'ouverture |
| `end_at` | TIMESTAMPTZ | Date/heure de clôture |
| `created_by` | UUID FK -> `core.admins` | Créateur |
| `created_at` | TIMESTAMPTZ | Horodatage création |
| `updated_at` | TIMESTAMPTZ | Horodatage MAJ |
| `public_key` | TEXT | Clé publique ElGamal du scrutin |
| `result_mode` | ENUM(public, hidden_until_close) | Visibilité résultats |

### `core.referendum_options`
| Colonne | Type | Description |
| --- | --- | --- |
| `id` | UUID PK |
| `referendum_id` | UUID FK -> `core.referendums` |
| `label` | TEXT |
| `order` | INT |
| `created_at` | TIMESTAMPTZ |

### `core.voters`
| Colonne | Type | Description |
| --- | --- | --- |
| `id` | UUID PK |
| `referendum_id` | UUID FK |
| `email` | CITEXT UNIQUE | Adresse de contact |
| `display_name` | TEXT | Nom affiché (optionnel) |
| `otp_secret` | BYTEA | Secret TOTP chiffré |
| `otp_delivery` | ENUM(email, sms, app) | Mode OTP |
| `eligibility_token_hash` | BYTEA | Hash du token d'éligibilité (SHA-256 + sel) |
| `public_signing_key` | TEXT | Clé publique signature votant |
| `registered_at` | TIMESTAMPTZ |
| `status` | ENUM(invited, activated, revoked) |

### `core.voter_sessions`
| Colonne | Type | Description |
| --- | --- | --- |
| `id` | UUID PK |
| `voter_id` | UUID FK -> `core.voters` |
| `refresh_token_hash` | BYTEA |
| `expires_at` | TIMESTAMPTZ |
| `created_at` | TIMESTAMPTZ |
| `device_info` | JSONB |
| `revoked_at` | TIMESTAMPTZ NULL |

### `ballots.encrypted_ballots`
| Colonne | Type | Description |
| --- | --- | --- |
| `id` | UUID PK |
| `referendum_id` | UUID FK |
| `ciphertext` | BYTEA | Bulletin chiffré (ElGamal) |
| `proof_commitment` | BYTEA | Preuve de connaissance nulle (ZKP) |
| `voter_pseudonym` | BYTEA | Hash du token d'éligibilité (avec nonce unique) |
| `signature` | BYTEA | Signature du votant (Ed25519) |
| `submitted_at` | TIMESTAMPTZ |
| `merkle_leaf_hash` | BYTEA |
| `merkle_root` | BYTEA |
| `audit_log_id` | UUID FK -> `audit.event_log` |

### `ballots.decryption_shares`
| Colonne | Type | Description |
| --- | --- | --- |
| `id` | UUID PK |
| `referendum_id` | UUID FK |
| `trustee_id` | UUID FK -> `core.trustees` |
| `share` | BYTEA | Partage de déchiffrement |
| `submitted_at` | TIMESTAMPTZ |

### `audit.event_log`
| Colonne | Type | Description |
| --- | --- | --- |
| `id` | UUID PK |
| `event_type` | TEXT | e.g. voter_registered, vote_submitted |
| `payload_hash` | BYTEA | Hash du payload JSON |
| `payload` | JSONB | Payload chiffré/signé |
| `created_at` | TIMESTAMPTZ |
| `merkle_root` | BYTEA | Racine de l'arbre à ce moment |
| `signature` | BYTEA | Signature service audit |

### `core.trustees`
| Colonne | Type | Description |
| --- | --- | --- |
| `id` | UUID PK |
| `name` | TEXT |
| `public_key` | TEXT |
| `role` | TEXT |
| `created_at` | TIMESTAMPTZ |

## Index & contraintes
- Index unique sur (`referendum_id`, `voter_pseudonym`) dans `encrypted_ballots`.
- Index par statut sur `referendums` et `voters`.
- Contraintes `CHECK` sur périodes de vote (start < end).
- Trigger pour recalculer `merkle_root` à chaque insertion de bulletin.

## Relations clés
- Un référendum possède N options, N votants, N bulletins.
- Les bulletins ne référencent pas directement le votant, uniquement un pseudonyme dérivé.
- Les journaux d'audit référencent tous les événements critiques.
