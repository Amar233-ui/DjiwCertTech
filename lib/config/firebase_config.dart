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

  // ANDROID
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCBOqGuAQ4rWc5kur91-vm88u_9TnQX6N4',
    appId: '1:258048048672:android:c79a8bfcf53449c6f24645',
    messagingSenderId: '258048048672',
    projectId: 'djiwcerttech-606cd',
    storageBucket: 'djiwcerttech-606cd.appspot.com',
  );

  // IOS
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDaW1ssGB6Aif0DgbyUFipMvQ8WnaMpPro',
    appId: '1:258048048672:ios:a4a722a78033eb8ef24645',
    messagingSenderId: '258048048672',
    projectId: 'djiwcerttech-606cd',
    storageBucket: 'djiwcerttech-606cd.appspot.com',
    iosBundleId: 'com.mondomaine.djiw',
  );

  // WEB
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCDGYXh7QIrueAEb7V_JSPrSpL-9ZFbSu8",
    authDomain: "djiwcerttech-606cd.firebaseapp.com",
    projectId: "djiwcerttech-606cd",
    storageBucket: "djiwcerttech-606cd.appspot.com",
    messagingSenderId: "258048048672",
    appId: "1:258048048672:web:7ec6bfb16799f0c7f24645",
    measurementId: "G-65EVC2YL2W",
  );
}
