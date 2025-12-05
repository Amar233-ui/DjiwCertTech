# 🔑 Configuration des Clés API

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

## 3. Redémarrer l'application

Après avoir configuré les clés :
```bash
flutter clean
flutter pub get
flutter run
```
