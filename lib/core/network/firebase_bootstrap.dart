import 'package:firebase_core/firebase_core.dart';

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static Future<bool> tryInit() async {
    try {
      if (Firebase.apps.isNotEmpty) return true;
      await Firebase.initializeApp();
      return true;
    } catch (_) {
      return false;
    }
  }

  static bool get isReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
