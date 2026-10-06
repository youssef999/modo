import 'i_reminder_scheduler.dart';
import 'reminder_scheduler_factory_io.dart'
    if (dart.library.js_interop) 'reminder_scheduler_factory_web.dart'
    as platform;

IReminderScheduler createReminderScheduler() =>
    platform.createPlatformReminderScheduler();
