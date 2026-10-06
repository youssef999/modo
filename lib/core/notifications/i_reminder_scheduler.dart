abstract class IReminderScheduler {
  Future<void> init();

  /// Asks the OS / browser for permission. Returns true when granted.
  Future<bool> requestPermission();

  /// Replaces any reminder with the same [id] by one that repeats every day
  /// at [hour]:[minute] local time.
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String channelName,
  });

  Future<void> cancel(int id);
}

class NoopReminderScheduler implements IReminderScheduler {
  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String channelName,
  }) async {}

  @override
  Future<void> cancel(int id) async {}
}

DateTime nextDailyOccurrence(DateTime now, int hour, int minute) {
  var next = DateTime(now.year, now.month, now.day, hour, minute);
  if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
  return next;
}
