import 'dart:io';

import 'i_reminder_scheduler.dart';
import 'local_reminder_scheduler.dart';

IReminderScheduler createPlatformReminderScheduler() {
  if (Platform.isAndroid || Platform.isIOS) return LocalReminderScheduler();
  return NoopReminderScheduler();
}
