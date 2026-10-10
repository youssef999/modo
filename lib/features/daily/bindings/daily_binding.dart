import 'package:get/get.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';

import '../controllers/plan_controller.dart';

class DailyBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PlanController>()) {
      Get.lazyPut<PlanController>(
        () => PlanController(Get.find<IStorage>()),
        fenix: true,
      );
    }
  }
}
