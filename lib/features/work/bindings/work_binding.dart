import 'package:get/get.dart';
import 'package:life_daily_app/core/network/firebase_bootstrap.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';
import 'package:life_daily_app/features/auth/controllers/auth_controller.dart';

import '../controllers/work_controller.dart';
import '../repositories/cached_work_repository.dart';
import '../repositories/firestore_work_repository.dart';
import '../repositories/i_work_repository.dart';
import '../repositories/local_work_repository.dart';

class WorkBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<IWorkRepository>()) {
      Get.lazyPut<IWorkRepository>(
        () => CachedWorkRepository(
          local: LocalWorkRepository(Get.find<IStorage>()),
          remote: FirebaseBootstrap.isReady ? FirestoreWorkRepository() : null,
          isCloudEnabled: () =>
              FirebaseBootstrap.isReady &&
              Get.isRegistered<AuthController>() &&
              Get.find<AuthController>().isBackedUp,
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<WorkController>()) {
      Get.lazyPut<WorkController>(
        () => WorkController(
          Get.find<IWorkRepository>(),
          Get.find<IStorage>(),
        ),
        fenix: true,
      );
    }
  }
}
