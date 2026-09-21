import 'package:get/get.dart';
import 'package:life_daily_app/core/network/firebase_bootstrap.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';
import 'package:life_daily_app/features/auth/controllers/auth_controller.dart';

import '../controllers/goals_controller.dart';
import '../repositories/cached_goal_repository.dart';
import '../repositories/firestore_goal_invite_repository.dart';
import '../repositories/firestore_goal_repository.dart';
import '../repositories/i_goal_invite_repository.dart';
import '../repositories/i_goal_repository.dart';
import '../repositories/local_goal_repository.dart';

class GoalsBinding extends Bindings {
  @override
  void dependencies() {
    if (FirebaseBootstrap.isReady && !Get.isRegistered<IGoalInviteRepository>()) {
      Get.lazyPut<IGoalInviteRepository>(
        () => FirestoreGoalInviteRepository(),
        fenix: true,
      );
    }

    if (!Get.isRegistered<IGoalRepository>()) {
      Get.lazyPut<IGoalRepository>(
        () => CachedGoalRepository(
          local: LocalGoalRepository(Get.find<IStorage>()),
          remote: FirebaseBootstrap.isReady ? FirestoreGoalRepository() : null,
          isCloudEnabled: () =>
              FirebaseBootstrap.isReady &&
              Get.isRegistered<AuthController>() &&
              Get.find<AuthController>().isLoggedIn,
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<GoalsController>()) {
      Get.lazyPut<GoalsController>(
        () => GoalsController(
          Get.find<IGoalRepository>(),
          Get.find<IStorage>(),
          inviteRepository: Get.isRegistered<IGoalInviteRepository>()
              ? Get.find<IGoalInviteRepository>()
              : null,
        ),
        fenix: true,
      );
    }
  }
}
