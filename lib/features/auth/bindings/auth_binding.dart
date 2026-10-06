import 'package:get/get.dart';
import 'package:life_daily_app/core/network/firebase_bootstrap.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';

import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../services/fake_auth_service.dart';
import '../services/fake_user_profile_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_user_profile_service.dart';
import '../services/i_auth_service.dart';
import '../services/i_user_profile_service.dart';

/// Account state must outlive the splash/login routes, so everything here is
/// permanent: GetX would otherwise dispose it when those routes are replaced
/// and the shell would start with a signed-out copy.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    final instance = GetInstance();
    if (!Get.isRegistered<IAuthService>()) {
      instance.lazyPut<IAuthService>(
        () => FirebaseBootstrap.isReady
            ? FirebaseAuthService()
            : FakeAuthService(),
        fenix: true,
        permanent: true,
      );
    }
    if (!Get.isRegistered<IUserProfileService>()) {
      instance.lazyPut<IUserProfileService>(
        () => FirebaseBootstrap.isReady
            ? FirestoreUserProfileService()
            : FakeUserProfileService(),
        fenix: true,
        permanent: true,
      );
    }
    if (!Get.isRegistered<ProfileController>()) {
      instance.lazyPut<ProfileController>(
        () => ProfileController(
          Get.find<IStorage>(),
          Get.find<IAuthService>(),
          Get.find<IUserProfileService>(),
        ),
        fenix: true,
        permanent: true,
      );
    }
    if (!Get.isRegistered<AuthController>()) {
      instance.lazyPut<AuthController>(
        () => AuthController(
          Get.find<IAuthService>(),
          Get.find<IUserProfileService>(),
        ),
        fenix: true,
        permanent: true,
      );
    }
  }
}
