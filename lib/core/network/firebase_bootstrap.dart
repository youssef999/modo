import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:life_daily_app/firebase_options.dart';

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static Future<bool> tryInit() async {
    try {
      if (Firebase.apps.isNotEmpty) return true;
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await _useLocalStorageOnWeb();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Browsers close IndexedDB while the tab is hidden (the Google popup opens
  /// as a new tab on phones), failing sign-in with "Database is
  /// closing/hidden". localStorage stays available and still survives reloads.
  static Future<void> _useLocalStorageOnWeb() async {
    if (!kIsWeb) return;
    try {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    } catch (_) {}
  }

  static bool get isReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
