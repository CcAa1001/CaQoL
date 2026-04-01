import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB_PSQVij_t684Do5eIbiiDt6vizGHAjBg',
    appId: '1:3442674846:web:4765c3a73866e47c08bf8f',
    messagingSenderId: '3442674846',
    projectId: 'caqol-1001',
    authDomain: 'caqol-1001.firebaseapp.com',
    storageBucket: 'caqol-1001.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCqx8IhNfmn4plB2dIqpL27JttjMJCyGy8',
    appId: '1:3442674846:android:8e7c19a8c6b4298308bf8f',
    messagingSenderId: '3442674846',
    projectId: 'caqol-1001',
    storageBucket: 'caqol-1001.firebasestorage.app',
  );
}
