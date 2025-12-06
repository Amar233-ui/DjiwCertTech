# 🔑 Configuration des Clés API

## 🚨 RÉSOLUTION RAPIDE - Erreur 403 sur Mobile

**Si votre API Gemini fonctionne en développement mais pas sur mobile (erreur 403), voici la solution rapide :**

1. Allez sur [Google Cloud Console](https://console.cloud.google.com/) > APIs & Services > Credentials
2. Cliquez sur votre clé API Gemini
3. Dans **"Application restrictions"**, sélectionnez **"None"** (pour tester rapidement)
   - ⚠️ Ou configurez "Android apps" avec votre package name : `com.example.djiwtech`
4. Dans **"API restrictions"**, assurez-vous que "Generative Language API" est autorisée
5. Cliquez sur "Save"
6. **Reconstruisez et réinstallez votre app** :
   ```bash
   flutter clean
   flutter build apk --release
   ```

**Le problème vient généralement des restrictions de clé API qui bloquent les requêtes depuis les appareils mobiles.**

---

## 1. Clé API Gemini (IA)

### Obtenir votre clé :
1. Allez sur [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Connectez-vous avec votre compte Google
3. Cliquez sur "Create API Key"
4. Copiez la clé générée

### Configuration :
Ouvrez `lib/config/constants.dart` et remplacez :
```dart
static const String geminiApiKey = 'VOTRE_CLE_GEMINI';
```
par :
```dart
static const String geminiApiKey = 'VOTRE_CLE_ICI';
```

## 2. Clé API OpenWeather (Météo)

### Obtenir votre clé :
1. Allez sur [OpenWeatherMap](https://openweathermap.org/api)
2. Créez un compte gratuit
3. Allez dans "API keys"
4. Copiez votre clé API

### Configuration :
Ouvrez `lib/config/constants.dart` et remplacez :
```dart
static const String openWeatherApiKey = 'VOTRE_CLE_OPENWEATHER';
```
par :
```dart
static const String openWeatherApiKey = 'VOTRE_CLE_ICI';
```

## 3. Résolution des problèmes

### ❌ Erreur 403 "Permission Denied" avec Gemini API

Si vous rencontrez une erreur 403, voici les étapes à suivre :

#### Vérifier la clé API :
1. **Vérifiez que votre clé API est valide** :
   - Allez sur [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Vérifiez que votre clé est toujours active
   - Si nécessaire, créez une nouvelle clé

2. **Activez l'API Gemini dans Google Cloud Console** :
   - Allez sur [Google Cloud Console](https://console.cloud.google.com/)
   - Sélectionnez votre projet
   - Allez dans "APIs & Services" > "Library"
   - Recherchez "Generative Language API" ou "Gemini API"
   - Cliquez sur "Enable" si elle n'est pas activée

3. **🔴 IMPORTANT : Configurez les restrictions de la clé API pour les apps mobiles** :
   
   Le problème 403 sur mobile est généralement causé par des restrictions de clé API. Voici comment le résoudre :
   
   **Étape 1 : Accédez à la configuration de votre clé API**
   - Allez sur [Google Cloud Console](https://console.cloud.google.com/)
   - Sélectionnez votre projet
   - Allez dans "APIs & Services" > "Credentials"
   - Cliquez sur votre clé API Gemini
   
   **Étape 2 : Configurez les restrictions d'API**
   - Dans "API restrictions", sélectionnez "Restrict key"
   - Ajoutez "Generative Language API" dans la liste des APIs autorisées
   - Si vous ne voyez pas cette API, assurez-vous qu'elle est activée (voir étape 2 ci-dessus)
   
   **Étape 3 : Configurez les restrictions d'application (CRUCIAL pour mobile)**
   
   **Option A : Pas de restrictions (Recommandé pour tester)**
   - Sélectionnez "None" dans "Application restrictions"
   - Cela permettra à votre clé API de fonctionner depuis n'importe quelle plateforme
   - ⚠️ **Attention** : Cette option est moins sécurisée, à utiliser uniquement pour tester
   
   **Option B : Restrictions Android (Recommandé pour production)**
   - Sélectionnez "Android apps" dans "Application restrictions"
   - Cliquez sur "Add an item"
   - Entrez le **Package name** de votre app : `com.example.djiwtech`
     (Vérifiez ce nom dans `android/app/build.gradle.kts` → `applicationId`)
   - Entrez le **SHA-1 certificate fingerprint** de votre clé de signature :
     
     **Pour obtenir le SHA-1 (Debug - pour tester) :**
     
     **Sur Windows :**
     ```powershell
     keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
     ```
     
     **Sur Mac/Linux :**
     ```bash
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```
     
     Cherchez la ligne "SHA1:" dans la sortie et copiez la valeur (sans les deux-points).
     
     **Pour Release (production) :**
     Utilisez la même commande mais avec votre keystore de production :
     ```bash
     keytool -list -v -keystore chemin/vers/votre/keystore.jks -alias votre_alias
     ```
     
   - Cliquez sur "Save"
   
   **Option C : Restrictions iOS (Si vous publiez sur iOS)**
   - Sélectionnez "iOS apps" dans "Application restrictions"
   - Ajoutez votre Bundle ID depuis Xcode ou votre Info.plist
   
   **⚠️ PROBLÈME COURANT :**
   - Si votre clé a des restrictions d'IP, elle ne fonctionnera PAS depuis une app mobile
   - Les restrictions d'IP bloquent toutes les requêtes depuis les appareils mobiles
   - **Solution** : Utilisez "None" ou "Android/iOS apps" au lieu des restrictions d'IP

4. **Activez la facturation** (si nécessaire) :
   - Certains projets nécessitent la facturation pour utiliser l'API
   - Allez dans "Billing" dans Google Cloud Console
   - Assurez-vous qu'un compte de facturation est lié au projet

5. **Vérifiez les quotas** :
   - Allez dans "APIs & Services" > "Quotas"
   - Vérifiez que vous n'avez pas dépassé les limites

### ❌ Problème de localisation sur mobile

Si la localisation ne fonctionne pas sur votre téléphone :

#### Sur Android :
1. **Vérifiez les permissions dans l'appareil** :
   - Paramètres > Applications > Votre App > Permissions > Localisation
   - Activez "Autoriser uniquement pendant l'utilisation" ou "Toujours"

2. **Activez la localisation GPS** :
   - Paramètres > Localisation > Activez le GPS

3. **Rebuilder l'application** après les modifications :
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

#### Sur iOS :
1. **Vérifiez les permissions dans l'appareil** :
   - Réglages > Votre App > Localisation
   - Activez "Lorsque l'app est active" ou "Toujours"

2. **Activez les services de localisation** :
   - Réglages > Confidentialité > Service de localisation > Activez

3. **Rebuilder l'application** :
   ```bash
   flutter clean
   flutter pub get
   flutter build ios --release
   ```

## 4. Redémarrer l'application

Après avoir configuré les clés ou résolu les problèmes :
```bash
flutter clean
flutter pub get
flutter run
```
