# Modèle de chiffrement recommandé

## Schéma de chiffrement
- **Type** : ElGamal sur courbe elliptique (Curve25519) avec possibilité de tally homomorphe.
- **Bibliothèque côté client** : libsodium (via package Flutter `flutter_sodium`) ou implémentation ElGamal personnalisée.
- **Côté serveur** : validation des preuves sans déchiffrement (vérification ZKP).

### Étapes
1. **Génération clé scrutin** :
   - L'autorité électorale génère une paire (sk_R, pk_R) ElGamal.
   - pk_R est publiée via l'API `/referendum/{id}` et signée.
   - sk_R est partagée entre `n` trustees via schéma de Shamir (seuil `t`).
2. **Initialisation votant** :
   - Le client génère une paire (sk_V, pk_V) Ed25519 pour signer.
   - pk_V est transmise à `/votants/register` ou importée depuis la liste.
   - Un token d'éligibilité unique est fourni, hashé côté serveur (pseudonyme).
3. **Chiffrement bulletin** :
   - Le vote est codé en vecteur binaire (option choisie = 1, autres = 0).
   - Pour un scrutin à choix unique : message `m` = option choisie (point sur courbe).
   - Le client choisit aléa `r`, calcule `C = (g^r, pk_R^r * m)`.
   - Produit une preuve de connaissance nulle (ZKP) attestant que `m` est bien une option valide.
4. **Signature requête** :
   - Le client signe `hash(headers + payload)` avec sk_V (Ed25519).
   - Ajoute timestamp et nonce pour prévenir replays.
5. **Soumission** :
   - Serveur vérifie signature, preuve ZKP, timestamp (fenêtre courte).
   - Calcule hash feuille `H = SHA256(ciphertext || proof || timestamp || nonce)`.
   - Ajoute H au Merkle tree courant et stocke chemin.
6. **Preuve pour le votant** :
   - Serveur retourne `vote_receipt` contenant `vote_id`, `merkle_root`, `merkle_path`, `timestamp`, `server_signature`.
   - Le client peut recalculer la racine et vérifier contre l'ancre publique (blockchain ou endpoint `/proof/latest-root`).
7. **Dépouillement** :
   - À la clôture, trustees calculent partages `sk_R_i` et réalisent déchiffrement homomorphe : multiplication des composantes `C2` puis application clé inverse.
   - Publication d'un rapport signé avec toutes les preuves et transcript du calcul.

## Gestion des clés et secrets
- Stocker `pk_R` dans base publique; `sk_R` jamais sur serveur API.
- Les secrets OTP sont chiffrés avec `AES-256-GCM` via une clé gérée par HSM.
- Utiliser `HKDF` pour dériver les clés de signature des tokens d'API.

## 2FA / OTP
- Auth initiale par email + mot de passe ou token unique.
- Deuxième facteur via OTP TOTP (RFC 6238) ou passkey (WebAuthn) côté WordPress.
- En mobilité, prendre en charge push OTP (Firebase) optionnel.

## Horodatage & signatures
- Chaque réponse critique contient `server_timestamp` + signature EdDSA avec clé du service.
- Les requêtes clients contiennent `client_timestamp` + nonce unique stocké dans Redis (TTL court) pour éviter replays.

## Preuves vérifiables
- Publication quotidienne de la racine Merkle sur un registre externe (blockchain, IPFS avec signature PGP).
- Endpoint `/vote/verify` retourne preuve Merkle + état du bulletin (comptabilisé ou invalidé) sans dévoiler le contenu.

## Conformité & anonymat
- Aucun lien direct entre `voter_id` et `encrypted_ballots`. Pseudonymes dérivés via `HMAC(secret_scrutin, eligibility_token)`.
- Suppression des refresh tokens inactifs passé la période électorale.
- Les journaux d'accès API sont pseudonymisés (hash IP + sel). 
