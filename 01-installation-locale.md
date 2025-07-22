# Exercice 1 : Installation locale de WordPress

## 🎯 Objectif
Installer WordPress en local sur votre ordinateur pour créer un environnement de développement sécurisé.

**Formateur** : Alexandre Auger - Dopamine 360  
**Durée estimée** : 45 minutes

---

## 📋 Prérequis

- Ordinateur Windows, Mac ou Linux
- Connexion internet pour télécharger les logiciels
- Espace disque disponible : 500 MB minimum

---

## 🛠️ Étape 1 : Installation de l'environnement local

### Option A : XAMPP (Windows/Mac/Linux)

1. **Télécharger XAMPP**
   - Rendez-vous sur [apachefriends.org](https://www.apachefriends.org)
   - Choisissez la version pour votre système
   - Téléchargez le fichier (environ 150 MB)

2. **Installer XAMPP**
   - Lancez l'installateur
   - Conservez les options par défaut
   - Installation dans `C:\xampp` (Windows) ou `/Applications/XAMPP` (Mac)

3. **Démarrer les services**
   - Ouvrez XAMPP Control Panel
   - Démarrez Apache
   - Démarrez MySQL

### Option B : Local by Flywheel (Recommandé par Dopamine 360)

1. **Télécharger Local**
   - Visitez [localwp.com](https://localwp.com)
   - Téléchargement gratuit
   - Plus simple pour les débutants

2. **Installation en 1 clic**
   - Interface intuitive
   - Gestion simplifiée
   - SSL automatique

---

## 🗄️ Étape 2 : Création de la base de données

### Si vous utilisez XAMPP :

1. **Accéder à phpMyAdmin**
   - Ouvrez votre navigateur
   - Allez sur `http://localhost/phpmyadmin`

2. **Créer une nouvelle base**
   - Cliquez sur "Nouvelle base de données"
   - Nom : `wordpress_rouen`
   - Interclassement : `utf8mb4_general_ci`
   - Cliquez sur "Créer"

### Si vous utilisez Local :
✅ La base de données est créée automatiquement !

---

## 📦 Étape 3 : Installation de WordPress

### Téléchargement de WordPress

1. **Obtenir WordPress en français**
   - Allez sur [fr.wordpress.org](https://fr.wordpress.org)
   - Cliquez sur "Obtenir WordPress"
   - Téléchargez le fichier .zip

2. **Extraire les fichiers**
   - **XAMPP** : Extrayez dans `C:\xampp\htdocs\formation-wordpress`
   - **Local** : Glissez le dossier dans l'interface

### Configuration de WordPress

1. **Accéder à l'installation**
   - XAMPP : `http://localhost/formation-wordpress`
   - Local : Cliquez sur "View Site"

2. **Écran de bienvenue**
   - Langue : Français
   - Cliquez sur "C'est parti !"

3. **Informations de la base de données**
   ```
   Nom de la base : wordpress_rouen
   Utilisateur : root
   Mot de passe : (vide pour XAMPP)
   Hôte : localhost
   Préfixe : wp_dopamine_
   ```

4. **Informations du site**
   ```
   Titre : Formation WordPress Rouen
   Utilisateur : admin_rouen
   Mot de passe : [Choisir un mot de passe fort]
   Email : votre@email.com
   ```

---

## ✅ Étape 4 : Vérification de l'installation

1. **Connexion à l'administration**
   - URL : `http://localhost/formation-wordpress/wp-admin`
   - Utilisateur : `admin_rouen`
   - Mot de passe : celui que vous avez choisi

2. **Vérifications essentielles**
   - [ ] Tableau de bord accessible
   - [ ] Site visible en frontend
   - [ ] Possibilité de créer une page
   - [ ] Upload d'une image

---

## 🎨 Étape 5 : Personnalisation initiale

1. **Réglages généraux**
   - Titre : "Mon site WordPress Rouen"
   - Slogan : "Créé lors de la formation Dopamine 360"
   - Fuseau horaire : Paris

2. **Permaliens**
   - Réglages > Permaliens
   - Choisir "Nom de l'article"
   - Enregistrer

3. **Page d'accueil**
   - Créer une page "Accueil"
   - Contenu : "Bienvenue sur mon site créé avec Dopamine 360 à Rouen"
   - Publier

---

## 🚀 Bonus : Optimisations recommandées

### Configuration PHP (XAMPP)
Éditer `php.ini` :
```ini
max_execution_time = 300
memory_limit = 256M
post_max_size = 64M
upload_max_filesize = 64M
```

### Activation du mode debug
Dans `wp-config.php` :
```php
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
define( 'WP_DEBUG_DISPLAY', false );
```

---

## ❓ Problèmes fréquents et solutions

### Erreur de connexion à la base de données
- Vérifier que MySQL est bien démarré
- Confirmer les identifiants de connexion
- Tester avec phpMyAdmin

### Page blanche
- Augmenter la mémoire PHP
- Désactiver les plugins
- Vérifier les logs d'erreur

### Problème de permissions
- Windows : Exécuter XAMPP en administrateur
- Mac/Linux : Vérifier les droits sur le dossier

---

## 📝 Points clés à retenir

1. **L'installation locale** permet de tester sans risque
2. **Local by Flywheel** est plus simple pour les débutants
3. **XAMPP** offre plus de contrôle pour les utilisateurs avancés
4. **Toujours sauvegarder** avant les modifications importantes

---

## 🎯 Validation de l'exercice

Vous avez réussi l'exercice si :
- ✅ WordPress est installé et fonctionnel
- ✅ Vous pouvez vous connecter à l'admin
- ✅ Vous avez créé votre première page
- ✅ Le site s'affiche correctement

---

## 📚 Pour aller plus loin

- Installer un thème gratuit depuis le répertoire
- Ajouter le plugin "Hello Dolly" pour tester
- Créer un utilisateur "Éditeur"
- Explorer les réglages de WordPress

---

## 💡 Astuce Dopamine 360

> "Un environnement local bien configuré est la base d'un développement WordPress serein. Prenez le temps de bien maîtriser cette étape !" - Alexandre Auger

---

## ⏭️ Prochain exercice

[Exercice 2 : Création de contenu →](02-creation-contenu.md)

---

*Exercice créé par Alexandre Auger - Dopamine 360 - Formation WordPress Rouen*
