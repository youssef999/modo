import 'package:get/get.dart';
import 'package:life_daily_app/core/notifications/i_reminder_scheduler.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';

import '../controllers/daily_reminder_controller.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<IReminderScheduler>()) {
      Get.lazyPut<IReminderScheduler>(NoopReminderScheduler.new, fenix: true);
    }
    if (!Get.isRegistered<DailyReminderController>()) {
      GetInstance().lazyPut<DailyReminderController>(
        () => DailyReminderController(
          Get.find<IStorage>(),
          Get.find<IReminderScheduler>(),
        ),
        fenix: true,
        permanent: true,
      );
    }
  }
}
