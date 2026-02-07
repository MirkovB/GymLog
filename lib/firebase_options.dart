import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA4nNZM_XrfxwZDZklizS0jHWnim8W9YaU',
    appId: '1:671099368114:android:207a3023e1c4dfecf14fab',
    messagingSenderId: '671099368114',
    projectId: 'gymlog-e6f44',
    storageBucket: 'gymlog-e6f44.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA4nNZM_XrfxwZDZklizS0jHWnim8W9YaU',
    appId: '1:671099368114:ios:placeholder',
    messagingSenderId: '671099368114',
    projectId: 'gymlog-e6f44',
    storageBucket: 'gymlog-e6f44.firebasestorage.app',
    iosBundleId: 'com.example.gymlog',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA4nNZM_XrfxwZDZklizS0jHWnim8W9YaU',
    appId: '1:671099368114:macos:placeholder',
    messagingSenderId: '671099368114',
    projectId: 'gymlog-e6f44',
    storageBucket: 'gymlog-e6f44.firebasestorage.app',
    iosBundleId: 'com.example.gymlog',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA4nNZM_XrfxwZDZklizS0jHWnim8W9YaU',
    appId: '1:671099368114:web:placeholder',
    messagingSenderId: '671099368114',
    projectId: 'gymlog-e6f44',
    storageBucket: 'gymlog-e6f44.firebasestorage.app',
    authDomain: 'gymlog-e6f44.firebaseapp.com',
  );
}
