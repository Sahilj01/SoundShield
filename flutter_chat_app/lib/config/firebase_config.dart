import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase configuration
/// Replace these values with your actual Firebase config
class FirebaseConfig {
  static const String apiKey = 'AIzaSyCA5LnGGoTK8DTAXiZtxK1X-L-yhn-zVHQ';
  static const String authDomain = 'chatappy';
  static const String projectId = 'chatappy-d0272';
  static const String storageBucket = 'chatappy-d0272.firebasestorage.app';
  static const String messagingSenderId = '1069745439729';
  static const String appId = '1:1069745439729:web:5870e71114e86969d5fa50';

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return web; // Use web config for Windows
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    authDomain: authDomain,
    storageBucket: storageBucket,
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket,
    iosBundleId: 'com.chatapp.flutterChatApp',
  );

  /// Initialize Firebase
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: currentPlatform,
    );
  }
}
