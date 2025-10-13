// This is a placeholder Firebase configuration file
// In a real app, you would generate this using the Firebase CLI
// Run: flutter packages pub global activate flutterfire_cli
// Then: flutterfire configure

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
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDGhbleDF5inMQWSVx7cxpUhPJMdIx8dBU',
    appId: '1:725800452245:web:c2d52af7d7823152ac9b9c',
    messagingSenderId: '725800452245',
    projectId: 'ready-ed',
    authDomain: 'ready-ed.firebaseapp.com',
    storageBucket: 'ready-ed.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyALqo4XqfNiBcTpog8DJj1HOA6sNAXYbck',
    appId: '1:725800452245:android:6979777c5b152af9ac9b9c',
    messagingSenderId: '725800452245',
    projectId: 'ready-ed',
    storageBucket: 'ready-ed.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:123456789:ios:demo',
    messagingSenderId: '123456789',
    projectId: 'readyed-demo',
    storageBucket: 'readyed-demo.appspot.com',
    iosBundleId: 'com.example.readyed',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:123456789:macos:demo',
    messagingSenderId: '123456789',
    projectId: 'readyed-demo',
    storageBucket: 'readyed-demo.appspot.com',
    iosBundleId: 'com.example.readyed',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDGhbleDF5inMQWSVx7cxpUhPJMdIx8dBU',
    appId: '1:725800452245:web:082a42a4bc6cb1e4ac9b9c',
    messagingSenderId: '725800452245',
    projectId: 'ready-ed',
    authDomain: 'ready-ed.firebaseapp.com',
    storageBucket: 'ready-ed.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDGhbleDF5inMQWSVx7cxpUhPJMdIx8dBU',
    appId: '1:725800452245:web:c2d52af7d7823152ac9b9c',
    messagingSenderId: '725800452245',
    projectId: 'ready-ed',
    authDomain: 'ready-ed.firebaseapp.com',
    storageBucket: 'ready-ed.firebasestorage.app',
  );

}
