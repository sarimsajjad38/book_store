// File generated for BookNest Firebase Configuration
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for BookNest.
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
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAL7Qf1DHAo5xuI7297wPz-xnWKH0Aljfg',
    appId: '1:246212820567:android:6516e442b3a86114de6d12',
    messagingSenderId: '246212820567',
    projectId: 'booknest-app-ef967',
    storageBucket: 'booknest-app-ef967.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAL7Qf1DHAo5xuI7297wPz-xnWKH0Aljfg',
    appId: '1:246212820567:web:6516e442b3a86114de6d12',
    messagingSenderId: '246212820567',
    projectId: 'booknest-app-ef967',
    storageBucket: 'booknest-app-ef967.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAL7Qf1DHAo5xuI7297wPz-xnWKH0Aljfg',
    appId: '1:246212820567:ios:6516e442b3a86114de6d12',
    messagingSenderId: '246212820567',
    projectId: 'booknest-app-ef967',
    storageBucket: 'booknest-app-ef967.firebasestorage.app',
    iosBundleId: 'com.booknest.app',
  );
}

