import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Plateforme non supportée');
    }
  }

  // Remplacez par vos propres configurations Firebase
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'VOTRE_API_KEY',
    appId: 'VOTRE_APP_ID',
    messagingSenderId: 'VOTRE_SENDER_ID',
    projectId: 'VOTRE_PROJECT_ID',
    storageBucket: 'VOTRE_STORAGE_BUCKET',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'VOTRE_API_KEY',
    appId: 'VOTRE_APP_ID',
    messagingSenderId: 'VOTRE_SENDER_ID',
    projectId: 'VOTRE_PROJECT_ID',
    storageBucket: 'VOTRE_STORAGE_BUCKET',
    iosBundleId: 'com.example.agriApp',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'VOTRE_API_KEY',
    appId: 'VOTRE_APP_ID',
    messagingSenderId: 'VOTRE_SENDER_ID',
    projectId: 'VOTRE_PROJECT_ID',
    storageBucket: 'VOTRE_STORAGE_BUCKET',
    authDomain: 'VOTRE_AUTH_DOMAIN',
  );
}