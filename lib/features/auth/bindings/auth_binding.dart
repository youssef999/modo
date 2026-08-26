import 'package:get/get.dart';
import 'package:life_daily_app/core/network/firebase_bootstrap.dart';

import '../controllers/auth_controller.dart';
import '../services/fake_auth_service.dart';
import '../services/fake_user_profile_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_user_profile_service.dart';
import '../services/i_auth_service.dart';
import '../services/i_user_profile_service.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<IAuthService>()) {
      Get.lazyPut<IAuthService>(
        () => FirebaseBootstrap.isReady
            ? FirebaseAuthService()
            : FakeAuthService(),
        fenix: true,
      );
    }
    if (!Get.isRegistered<IUserProfileService>()) {
      Get.lazyPut<IUserProfileService>(
        () => FirebaseBootstrap.isReady
            ? FirestoreUserProfileService()
            : FakeUserProfileService(),
        fenix: true,
      );
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(
        () => AuthController(
          Get.find<IAuthService>(),
          Get.find<IUserProfileService>(),
        ),
        fenix: true,
      );
    }
  }
}
