// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBwO66IE8TqkckvoR6KFYJJM48XQud5o9A',
    appId: '1:1077273680968:web:293573c7d2675f479e8c7d',
    messagingSenderId: '1077273680968',
    projectId: 'test-1901f',
    authDomain: 'test-1901f.firebaseapp.com',
    databaseURL: 'https://test-1901f-default-rtdb.firebaseio.com',
    storageBucket: 'test-1901f.appspot.com',
    measurementId: 'G-BG8C32N80M',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC4VbCcZ97s2p_HrYWWlWIUk5HTHMD4lyk',
    appId: '1:1077273680968:android:b6a836eecbdca0079e8c7d',
    messagingSenderId: '1077273680968',
    projectId: 'test-1901f',
    databaseURL: 'https://test-1901f-default-rtdb.firebaseio.com',
    storageBucket: 'test-1901f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAFxKr1GusFPLUza1JzZMkhW3ykbN3gQA0',
    appId: '1:1077273680968:ios:33e382963c29bebe9e8c7d',
    messagingSenderId: '1077273680968',
    projectId: 'test-1901f',
    databaseURL: 'https://test-1901f-default-rtdb.firebaseio.com',
    storageBucket: 'test-1901f.appspot.com',
    androidClientId: '1077273680968-cl5292ip6a3ick20ms46m7088brtts2b.apps.googleusercontent.com',
    iosClientId: '1077273680968-reels8p1pgq2o41kjrr9b2cschgtgecf.apps.googleusercontent.com',
    iosBundleId: 'com.example.capstone',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAFxKr1GusFPLUza1JzZMkhW3ykbN3gQA0',
    appId: '1:1077273680968:ios:ffff4cbe7d84c8949e8c7d',
    messagingSenderId: '1077273680968',
    projectId: 'test-1901f',
    databaseURL: 'https://test-1901f-default-rtdb.firebaseio.com',
    storageBucket: 'test-1901f.appspot.com',
    androidClientId: '1077273680968-cl5292ip6a3ick20ms46m7088brtts2b.apps.googleusercontent.com',
    iosClientId: '1077273680968-qrck7oahmnsjb2pk98ikj7fepjv55gdd.apps.googleusercontent.com',
    iosBundleId: 'com.example.capstone.RunnerTests',
  );
}
