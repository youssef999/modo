import 'package:get/get.dart';
import 'package:life_daily_app/core/network/firebase_bootstrap.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';
import 'package:life_daily_app/features/auth/controllers/auth_controller.dart';

import '../controllers/finance_controller.dart';
import '../repositories/cached_finance_repository.dart';
import '../repositories/firestore_finance_repository.dart';
import '../repositories/i_finance_repository.dart';
import '../repositories/local_finance_repository.dart';

/// Permanent so the signed-in data survives the login route being replaced.
class FinanceBinding extends Bindings {
  @override
  void dependencies() {
    final instance = GetInstance();
    if (!Get.isRegistered<IFinanceRepository>()) {
      instance.lazyPut<IFinanceRepository>(
        () => CachedFinanceRepository(
          local: LocalFinanceRepository(Get.find<IStorage>()),
          remote: FirebaseBootstrap.isReady
              ? FirestoreFinanceRepository()
              : null,
          isCloudEnabled: () =>
              FirebaseBootstrap.isReady &&
              Get.isRegistered<AuthController>() &&
              Get.find<AuthController>().isBackedUp,
        ),
        fenix: true,
        permanent: true,
      );
    }
    if (!Get.isRegistered<FinanceController>()) {
      instance.lazyPut<FinanceController>(
        () => FinanceController(Get.find<IFinanceRepository>()),
        fenix: true,
        permanent: true,
      );
    }
  }
}
