import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// DefaultFirebaseOptions for your Firebase project.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCW1KaZ26oixGWU8Dk_jP99lTWFb97WxDg',
    appId: '1:199001956949:android:5a6e6bd9a4ab1582bcaadc',
    messagingSenderId: '199001956949',
    projectId: 'plantcare-1w',
    storageBucket: 'plantcare-1w.firebasestorage.app',
  );
}