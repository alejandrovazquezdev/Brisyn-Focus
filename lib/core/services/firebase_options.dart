// Firebase configuration for Brisyn Focus
// Generated from Firebase Console setup

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return web; // Use web config for Windows
      case TargetPlatform.linux:
        return web; // Use web config for Linux
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCCn9IhFS5M8-HYB7eilyhXPEdAdW0-mR8',
    appId: '1:150222395140:web:340b908471758b538ea251',
    messagingSenderId: '150222395140',
    projectId: 'brisyn-focus',
    authDomain: 'brisyn-focus.firebaseapp.com',
    storageBucket: 'brisyn-focus.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDCKeGnoGv_Z-Oyy2Z9muTIr9I9RP3NejU',
    appId: '1:150222395140:android:c4d878351671c0348ea251',
    messagingSenderId: '150222395140',
    projectId: 'brisyn-focus',
    storageBucket: 'brisyn-focus.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAm-cL4H07V5K9Qpw_kI_9ud4JwjpRKHyg',
    appId: '1:150222395140:ios:a1ee1b0a5ff966808ea251',
    messagingSenderId: '150222395140',
    projectId: 'brisyn-focus',
    storageBucket: 'brisyn-focus.firebasestorage.app',
    iosBundleId: 'com.brisyn.focus',
    iosClientId: '150222395140-i35k566eods32brujsudb2s1mjkubur4.apps.googleusercontent.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAm-cL4H07V5K9Qpw_kI_9ud4JwjpRKHyg',
    appId: '1:150222395140:ios:a1ee1b0a5ff966808ea251',
    messagingSenderId: '150222395140',
    projectId: 'brisyn-focus',
    storageBucket: 'brisyn-focus.firebasestorage.app',
    iosBundleId: 'com.brisyn.focus',
    iosClientId: '150222395140-i35k566eods32brujsudb2s1mjkubur4.apps.googleusercontent.com',
  );
}
