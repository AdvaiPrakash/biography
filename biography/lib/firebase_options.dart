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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDI2cbapoZfZBc3Lu_uH2ucCx9dPngBoKU',
    appId: '1:49854212410:web:53f3cb44832266cc7c6c803',
    messagingSenderId: '49854212410',
    projectId: 'biography-b7be4',
    authDomain: 'biography-b7be4.firebaseapp.com',
    storageBucket: 'biography-b7be4.firebasestorage.app',
    measurementId: 'G-SZDCXL2PM3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDI2cbapoZfZBc3Lu_uH2ucCx9dPngBoKU',
    appId: '1:49854212410:web:959a5ebd86f1c06ec6c803',
    messagingSenderId: '49854212410',
    projectId: 'biography-b7be4',
    storageBucket: 'biography-b7be4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDI2cbapoZfZBc3Lu_uH2ucCx9dPngBoKU',
    appId: '1:49854212410:web:959a5ebd86f1c06ec6c803',
    messagingSenderId: '49854212410',
    projectId: 'biography-b7be4',
    storageBucket: 'biography-b7be4.firebasestorage.app',
    iosBundleId: 'com.example.biography',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDI2cbapoZfZBc3Lu_uH2ucCx9dPngBoKU',
    appId: '1:49854212410:web:959a5ebd86f1c06ec6c803',
    messagingSenderId: '49854212410',
    projectId: 'biography-b7be4',
    storageBucket: 'biography-b7be4.firebasestorage.app',
    iosBundleId: 'com.example.biography',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDI2cbapoZfZBc3Lu_uH2ucCx9dPngBoKU',
    appId: '1:49854212410:web:959a5ebd86f1c06ec6c803',
    messagingSenderId: '49854212410',
    projectId: 'biography-b7be4',
    storageBucket: 'biography-b7be4.firebasestorage.app',
  );
}
