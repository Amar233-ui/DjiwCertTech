# 📚 Guide Complet - DjiwCertTech

## 🔑 Configuration des Clés API

### 1. Clé Gemini (IA)
1. Allez sur [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Créez une clé API
3. Ouvrez `lib/config/constants.dart`
4. Remplacez `'VOTRE_CLE_GEMINI'` par votre clé

### 2. Clé OpenWeather (Météo)
1. Allez sur [OpenWeatherMap](https://openweathermap.org/api)
2. Créez un compte gratuit
3. Copiez votre clé API
4. Ouvrez `lib/config/constants.dart`
5. Remplacez `'VOTRE_CLE_OPENWEATHER'` par votre clé

## 🖥️ Back-Office - Nouvelles Fonctionnalités

### ✅ Gestion des Formations
- **Ajouter une formation** : Cliquez sur "Nouvelle formation"
- **Modifier** : Cliquez sur l'icône d'édition
- **Publier/Dépublier** : Utilisez le bouton œil
- **Supprimer** : Cliquez sur l'icône poubelle

### ✅ Gestion des Utilisateurs
- **Voir tous les utilisateurs** : Menu "Utilisateurs"
- **Informations affichées** : Nom, Email, Téléphone, Région, Zone, Rôle
- **Promouvoir en vendeur** : Cliquez sur "Vendeur" dans les actions
- **Voir les détails** : Cliquez sur l'icône œil

## 📱 Application Mobile - Nouvelles Fonctionnalités

### ✅ Scanner QR Code
1. Ouvrez le drawer menu
2. Cliquez sur "Scanner QR Code"
3. Scannez le QR code d'un produit
4. Consultez les informations de traçabilité

### ✅ Devenir Vendeur
1. Ouvrez le drawer menu
2. Cliquez sur "Devenir Vendeur"
3. Remplissez le formulaire :
   - Nom de l'entreprise
   - Description
   - Adresse
   - Numéro de certification (optionnel)
   - Document de certification (obligatoire)
4. Envoyez la demande
5. L'administrateur validera votre demande dans le back-office

## 🔧 Installation des Dépendances

```bash
flutter pub get
```

Nouvelles dépendances ajoutées :
- `mobile_scanner: ^5.2.3` - Pour scanner les QR codes

## 📋 Permissions Requises

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>Nous avons besoin d'accéder à votre caméra pour scanner les QR codes</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Nous avons besoin d'accéder à vos photos pour la certification</string>
```

## 🎯 Utilisation

### Météo
Une fois la clé OpenWeather configurée, la météo sera automatiquement disponible dans l'application.

### Formations
Les formations peuvent maintenant être ajoutées et gérées depuis le back-office.

### Utilisateurs
Tous les utilisateurs sont visibles dans le back-office avec leurs informations complètes.

### QR Codes
Les QR codes peuvent être scannés pour vérifier la traçabilité des produits.

### Demandes Vendeur
Les utilisateurs peuvent demander à devenir vendeurs, et les administrateurs peuvent les approuver depuis le back-office.
