// lib/firebase_options.dart
// 🔥 REPLACE THESE VALUES WITH YOUR FIREBASE PROJECT CONFIG
// Go to: Firebase Console → Project Settings → Your Apps → Web App → SDK Setup
// Run: flutterfire configure  (recommended way to auto-generate this file)

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  // ──────────────────────────────────────────────────
  // ✏️  PASTE YOUR OWN VALUES BELOW

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAUPKibeIHkgsk8f7oJ0AxVbqnYq3irWJg',
    appId: '1:242308040112:web:ad47b6989dfe6b5d558275',
    messagingSenderId: '242308040112',
    projectId: 'kirana-shop-394d8',
    authDomain: 'kirana-shop-394d8.firebaseapp.com',
    databaseURL: 'https://kirana-shop-394d8-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'kirana-shop-394d8.firebasestorage.app',
    measurementId: 'G-HWGNR9FR9R',
  );

  // ──────────────────────────────────────────────────

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCboSOzmSwTEzLtSaVcVSJM9F1fyS_cNAE',
    appId: '1:242308040112:android:003a87e6f42875b7558275',
    messagingSenderId: '242308040112',
    projectId: 'kirana-shop-394d8',
    databaseURL: 'https://kirana-shop-394d8-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'kirana-shop-394d8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    databaseURL: 'https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'com.example.kiranaShop',
  );
}