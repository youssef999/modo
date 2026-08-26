import 'package:get/get.dart';

import '../controllers/locale_controller.dart';
import '../controllers/theme_controller.dart';
import '../storage/i_storage.dart';
import '../storage/local_storage.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<IStorage>()) {
      Get.lazyPut<IStorage>(LocalStorage.new, fenix: true);
    }
    if (!Get.isRegistered<ThemeController>()) {
      Get.lazyPut<ThemeController>(
        () => ThemeController(Get.find<IStorage>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<LocaleController>()) {
      Get.lazyPut<LocaleController>(
        () => LocaleController(Get.find<IStorage>()),
        fenix: true,
      );
    }
  }
}
