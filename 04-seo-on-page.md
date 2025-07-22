# Exercice 4 : Optimisation SEO on-page pour Rouen

## 🎯 Objectif
Optimiser une page WordPress pour le référencement local à Rouen en appliquant les meilleures pratiques SEO.

**Formateur** : Alexandre Auger - Dopamine 360  
**Durée estimée** : 1h30  
**Niveau** : Intermédiaire

---

## 📋 Contexte de l'exercice

Vous êtes propriétaire d'un restaurant à Rouen et vous souhaitez optimiser votre page "Restaurant" pour apparaître dans les premières positions sur Google pour la recherche "restaurant Rouen".

---

## 🛠️ Partie 1 : Installation et configuration de Yoast SEO

### Étape 1 : Installation du plugin

1. **Dans votre tableau de bord WordPress**
   - Extensions > Ajouter
   - Rechercher "Yoast SEO"
   - Installer et Activer

2. **Configuration initiale**
   - Suivre l'assistant de configuration
   - Type de site : "Petite entreprise locale"
   - Nom de l'organisation : "Votre Restaurant Rouen"

### Étape 2 : Paramètres essentiels

1. **SEO > Réglages généraux**
   - Onglet "Fonctionnalités"
   - Activer "Plans de site XML"
   - Activer "Fil d'Ariane"

2. **SEO > Apparence dans les résultats**
   ```
   Titre du site : Restaurant [Nom] - Cuisine française à Rouen
   Séparateur : | 
   ```

---

## 📝 Partie 2 : Création et optimisation de la page

### Étape 1 : Structure de la page

Créez une nouvelle page avec le titre : "Restaurant [Nom] - Cuisine Française au Cœur de Rouen"

**Structure recommandée :**

```markdown
# H1 : Restaurant [Nom] - Cuisine Française au Cœur de Rouen

## H2 : Notre restaurant gastronomique à Rouen

[Paragraphe d'introduction avec "restaurant Rouen" placé naturellement]

## H2 : Notre carte : saveurs normandes et créativité

### H3 : Entrées raffinées
### H3 : Plats signature
### H3 : Desserts gourmands

## H2 : Un cadre unique près de la Cathédrale de Rouen

[Description avec mentions géographiques locales]

## H2 : Réservez votre table dans notre restaurant à Rouen

## H2 : Informations pratiques

### H3 : Horaires d'ouverture
### H3 : Comment venir à notre restaurant
### H3 : Parking à proximité
```

### Étape 2 : Optimisation du contenu

1. **Densité de mots-clés**
   - "Restaurant Rouen" : 3-4 fois
   - "Restaurant gastronomique Rouen" : 1-2 fois
   - "Cuisine française Rouen" : 1-2 fois
   - Variations : "resto Rouen", "dîner Rouen"

2. **Mots-clés LSI (sémantiquement liés)**
   - Seine-Maritime
   - Centre-ville Rouen
   - Place du Vieux-Marché
   - Cathédrale de Rouen
   - Cuisine normande
   - Produits locaux

---

## 🎨 Partie 3 : Optimisation des images

### Étape 1 : Préparation des images

1. **Nommage des fichiers**
   ```
   ❌ IMG_1234.jpg
   ✅ restaurant-rouen-salle-principale.jpg
   ✅ plat-gastronomique-restaurant-nom-rouen.jpg
   ✅ terrasse-restaurant-centre-ville-rouen.jpg
   ```

2. **Compression**
   - Utiliser TinyPNG ou Imagify
   - Taille cible : < 150KB par image
   - Format : JPEG pour photos, PNG pour logos

### Étape 2 : Attributs dans WordPress

1. **Texte alternatif (Alt)**
   ```
   Image 1 : "Salle principale du restaurant [Nom] à Rouen"
   Image 2 : "Plat signature - Restaurant gastronomique Rouen"
   Image 3 : "Vue sur la Cathédrale depuis notre terrasse"
   ```

2. **Titre et légende**
   - Titre : Description courte
   - Légende : Information complémentaire avec mot-clé

---

## 🔧 Partie 4 : Configuration Yoast SEO

### Dans l'éditeur de page :

1. **Requête cible**
   - Principal : "restaurant Rouen"
   - Secondaire : "restaurant gastronomique Rouen"

2. **Méta titre** (55-60 caractères)
   ```
   Restaurant [Nom] Rouen | Cuisine Gastronomique Centre-Ville
   ```

3. **Méta description** (150-160 caractères)
   ```
   Découvrez notre restaurant gastronomique au cœur de Rouen. 
   Cuisine française raffinée, produits locaux, cadre exceptionnel. 
   Réservez votre table ☎ 02.XX.XX.XX.XX
   ```

4. **URL optimisée**
   ```
   https://votresite.fr/restaurant-gastronomique-rouen
   ```

---

## 📍 Partie 5 : SEO local avancé

### Étape 1 : Microdonnées locales

Ajouter dans le contenu :
```html
<div itemscope itemtype="http://schema.org/Restaurant">
  <h3 itemprop="name">Restaurant [Nom]</h3>
  <div itemprop="address" itemscope itemtype="http://schema.org/PostalAddress">
    <span itemprop="streetAddress">123 Rue du Gros-Horloge</span>
    <span itemprop="addressLocality">Rouen</span>
    <span itemprop="postalCode">76000</span>
  </div>
  <span itemprop="telephone">02 XX XX XX XX</span>
</div>
```

### Étape 2 : Contenu géolocalisé

Intégrer naturellement :
- "À 5 minutes à pied de la Cathédrale de Rouen"
- "Face au Palais de Justice"
- "Parking Vieux-Marché à 100m"
- "Accessible en métro (station Théâtre des Arts)"

---

## ✅ Partie 6 : Checklist de vérification

### Contenu
- [ ] H1 unique avec mot-clé principal
- [ ] 600+ mots de contenu
- [ ] Structure Hn logique
- [ ] Mots-clés placés naturellement
- [ ] Mentions géographiques locales

### Technique
- [ ] URL optimisée
- [ ] Méta titre < 60 caractères
- [ ] Méta description < 160 caractères
- [ ] Images optimisées avec alt
- [ ] Temps de chargement < 3 secondes

### Yoast SEO
- [ ] Feu vert pour la lisibilité
- [ ] Feu vert pour le SEO
- [ ] Requête cible configurée
- [ ] Pas de problèmes signalés

---

## 🚀 Partie 7 : Aller plus loin

### Créer des pages satellites
1. "Menu du restaurant [Nom] à Rouen"
2. "Événements privés - Restaurant Rouen"
3. "Avis clients - Restaurant gastronomique Rouen"

### Optimisation de la page d'accueil
- Balise title : "Restaurant [Nom] | Gastronomie Française Rouen"
- H1 : "Bienvenue au Restaurant [Nom] à Rouen"
- CTA visible : "Réserver une table"

### Maillage interne
- Lier vers la page "Menu"
- Lier vers "Contact et accès"
- Lier vers "Événements"

---

## 💡 Conseils pro de Dopamine 360

> **Le secret du SEO local** : "Ne vous contentez pas de mentionner Rouen. Racontez une histoire qui ancre votre établissement dans le tissu local. Parlez des producteurs normands, de votre vue sur la Seine, de votre proximité avec les monuments historiques." - Alexandre Auger

### Erreurs courantes à éviter
- ❌ Sur-optimisation (bourrage de mots-clés)
- ❌ Contenu dupliqué depuis d'autres sites
- ❌ Négliger la version mobile
- ❌ Oublier Google My Business

---

## 📊 Résultats attendus

Après optimisation, vous devriez observer :
- ✅ Score Yoast SEO vert
- ✅ Score de lisibilité vert
- ✅ Apparition dans le Local Pack Google
- ✅ Augmentation du trafic organique local

---

## 🎯 Validation de l'exercice

Partagez votre page optimisée avec le formateur pour validation :
1. URL de la page
2. Capture du score Yoast
3. Position actuelle sur "restaurant Rouen"

---

## 📚 Ressources complémentaires

- [Guide SEO local Google](https://developers.google.com/search/docs/advanced/guidelines/local)
- [Documentation Yoast SEO](https://yoast.com/wordpress/plugins/seo/)
- [Blog Dopamine 360](https://dopamine360.fr/blog) - Section SEO

---

## ⏭️ Prochain exercice

[Exercice 5 : Création d'un formulaire de contact →](05-formulaire-contact.md)

---

*Exercice créé par Alexandre Auger - Dopamine 360 - Expert SEO & Formation WordPress Rouen*

**#SEO #WordPress #Rouen #Dopamine360 #RéférencementLocal**
