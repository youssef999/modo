import 'package:get/get.dart';
import 'package:life_daily_app/core/network/firebase_bootstrap.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';
import 'package:life_daily_app/features/auth/controllers/auth_controller.dart';

import '../controllers/journal_controller.dart';
import '../repositories/cached_journal_repository.dart';
import '../repositories/firestore_journal_repository.dart';
import '../repositories/i_journal_repository.dart';
import '../repositories/local_journal_repository.dart';

class JournalBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<IJournalRepository>()) {
      Get.lazyPut<IJournalRepository>(
        () => CachedJournalRepository(
          local: LocalJournalRepository(Get.find<IStorage>()),
          remote: FirebaseBootstrap.isReady
              ? FirestoreJournalRepository()
              : null,
          isCloudEnabled: () =>
              FirebaseBootstrap.isReady &&
              Get.isRegistered<AuthController>() &&
              Get.find<AuthController>().isBackedUp,
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<JournalController>()) {
      Get.lazyPut<JournalController>(
        () => JournalController(
          Get.find<IJournalRepository>(),
          Get.find<IStorage>(),
        ),
        fenix: true,
      );
    }
  }
}
