import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'i_reminder_scheduler.dart';
import 'reminder_scheduler_factory.dart';

class ReminderBootstrap {
  ReminderBootstrap._();

  static Future<void> init() async {
    final scheduler = createReminderScheduler();
    try {
      await scheduler.init();
      Get.put<IReminderScheduler>(scheduler, permanent: true);
    } catch (error, stack) {
      debugPrint('Reminder init failed: $error\n$stack');
      Get.put<IReminderScheduler>(NoopReminderScheduler(), permanent: true);
    }
  }
}
