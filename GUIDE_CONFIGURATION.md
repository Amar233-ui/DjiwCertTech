# 🔧 Guide de Configuration - DjiwCertTech

## 📋 Configuration Requise

### 1. Clé API Gemini

Pour activer toutes les fonctionnalités IA, vous devez configurer votre clé API Gemini :

1. Allez sur [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Créez une nouvelle clé API
3. Ouvrez `lib/config/constants.dart`
4. Remplacez `'VOTRE_CLE_GEMINI'` par votre clé API

```dart
static const String geminiApiKey = 'VOTRE_CLE_GEMINI'; // ← Remplacez ici
```

### 2. Permissions pour Image Picker

#### Android
Ajoutez dans `android/app/src/main/AndroidManifest.xml` :
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

#### iOS
Ajoutez dans `ios/Runner/Info.plist` :
```xml
<key>NSCameraUsageDescription</key>
<string>Nous avons besoin d'accéder à votre caméra pour prendre une photo de preuve de réception</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Nous avons besoin d'accéder à vos photos pour la preuve de réception</string>
```

### 3. Firebase Storage Rules

Assurez-vous que vos règles Firebase Storage autorisent l'upload :

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### 4. Installation des Dépendances

```bash
flutter pub get
```

## 🎯 Utilisation des Nouvelles Fonctionnalités

### Recommandations IA de Semences
1. Ouvrez le drawer menu
2. Cliquez sur "Recommandations IA"
3. Sélectionnez votre région, zone et saison
4. Obtenez des recommandations personnalisées

### Calculateur de Quantité
1. Ouvrez un produit dans le catalogue
2. Cliquez sur "Calculer la quantité"
3. Entrez votre superficie
4. Obtenez la quantité exacte nécessaire

### Preuve de Réception
1. Allez dans "Mes Commandes"
2. Ouvrez une commande livrée
3. Cliquez sur "Prendre une photo"
4. Envoyez la preuve de réception

### Gestion de Champs
1. Ouvrez le drawer menu
2. Cliquez sur "Gestion de Champs"
3. Entrez vos informations
4. Obtenez des conseils personnalisés par IA

### Formations Recommandées
1. Allez dans "Formation"
2. Cliquez sur l'icône IA en haut à droite
3. Consultez les formations recommandées selon votre profil

## 🔐 Accès Vendeur

Pour accéder à l'interface vendeur, l'email de l'utilisateur doit contenir "vendeur" ou le rôle doit être défini dans Firestore.
