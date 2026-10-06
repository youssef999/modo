import 'i_reminder_scheduler.dart';
import 'web_reminder_scheduler.dart';

IReminderScheduler createPlatformReminderScheduler() => WebReminderScheduler();
