# DjiwCertTech - Administration (Back-Office)

Panneau d'administration web pour la gestion de la plateforme DjiwCertTech.

## 🚀 Démarrage rapide

### Option 1 : Serveur HTTP (Recommandé)

1. **Avec Node.js** :
   ```bash
   cd admin
   node server.js
   ```
   Puis ouvrez votre navigateur sur : `http://localhost:8080`

2. **Avec Python** (si Node.js n'est pas installé) :
   ```bash
   cd admin
   python -m http.server 8080
   ```
   Puis ouvrez votre navigateur sur : `http://localhost:8080`

3. **Avec PowerShell** (Windows) :
   ```powershell
   cd admin
   .\start-server.bat
   ```

### Option 2 : Serveur de développement Flutter

Si vous avez déjà Flutter installé, vous pouvez utiliser le serveur web intégré :

```bash
cd admin
flutter run -d chrome --web-port=8080
```

## ⚠️ Important

**Ne pas ouvrir directement `index.html` dans le navigateur** (protocole `file://`). 
Vous devez utiliser un serveur HTTP pour éviter les erreurs CORS.

## Fonctionnalités

### ✅ Vérification des Vendeurs
- Liste de tous les vendeurs
- Filtrage par statut (Tous, En attente, Approuvés, Rejetés)
- Recherche de vendeurs
- Approbation/Rejet des vendeurs avec raison
- Visualisation des documents de certification

### ✅ Gestion du Stock Global
- Vue d'ensemble de tous les produits
- Affichage du stock disponible
- Statut de disponibilité
- Modification et suppression de produits

### ✅ Gestion des Subventions
- Création de nouvelles subventions
- Suivi des bénéficiaires
- Gestion des dates et montants
- Statut des subventions (Active, Expirée, À venir)

### ✅ Analyse des Risques Climatiques
- Visualisation des alertes météorologiques
- Niveaux de risque (Faible, Moyen, Élevé)
- Informations par région

### ✅ Panneau de Supervision de la Logistique
- Suivi des commandes en cours
- Mise à jour du statut des commandes
- Statistiques de livraison
- Gestion du cycle de vie des commandes

### ✅ Contrôle des Contenus de Formation
- Liste de toutes les formations
- Publication/Dépublication
- Modification et suppression
- Gestion des catégories

### ✅ Accès aux Statistiques
- Ventes par zone géographique
- Pics de demande (graphique temporel)
- Produits les plus vendus
- Filtrage par période (Semaine, Mois, Année)

## Configuration Firebase

Le back-office utilise la même configuration Firebase que l'application Flutter. Les collections utilisées sont :

- `users` - Utilisateurs
- `vendors` - Vendeurs certifiés
- `products` - Produits/Semences
- `orders` - Commandes
- `training` - Formations
- `subsidies` - Subventions
- `weatherAlerts` - Alertes météorologiques

## Structure des Rôles

Pour qu'un utilisateur puisse accéder au back-office, son document dans la collection `users` doit avoir :
- `role: 'admin'` OU
- `isAdmin: true`

## Dépendances

- Firebase SDK (chargé via CDN)
- Chart.js (chargé via CDN pour les graphiques)
- Font Awesome (chargé via CDN pour les icônes)

## Notes

- Certaines fonctionnalités nécessitent des améliorations (modales complètes, validation des formulaires)
- Les graphiques utilisent Chart.js et se chargent automatiquement
- Le design est responsive et s'adapte aux différentes tailles d'écran

