class WeekProgress {
  const WeekProgress({
    required this.done,
    required this.total,
    required this.streak,
  });

  final int done;
  final int total;
  final int streak;

  int get percent {
    if (total <= 0) return 0;
    return ((done / total) * 100).round().clamp(0, 100);
  }

  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime weekStart(DateTime now) {
    final day = dateOnly(now);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  static bool inWeek(DateTime value, DateTime now) {
    final start = weekStart(now);
    final end = start.add(const Duration(days: 7));
    final day = dateOnly(value);
    return !day.isBefore(start) && day.isBefore(end);
  }

  static String dayKey(DateTime date) {
    final value = dateOnly(date);
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  static int streakDays(Set<String> activeDays, DateTime now) {
    var count = 0;
    var cursor = dateOnly(now);
    while (activeDays.contains(dayKey(cursor))) {
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }
}
