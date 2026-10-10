/// A planning span. Tasks are planned for one period; habits repeat once per
/// period. Every period is identified by its first day.
enum PlanPeriod {
  day,
  week,
  month,
  year;

  /// Weeks run Saturday → Friday.
  static const int weekStartDay = DateTime.saturday;

  static PlanPeriod fromName(String? raw) {
    for (final period in values) {
      if (period.name == raw) return period;
    }
    return PlanPeriod.day;
  }

  /// First day of the period containing [date].
  DateTime startOf(DateTime date) {
    return switch (this) {
      PlanPeriod.day => DateTime(date.year, date.month, date.day),
      PlanPeriod.week => DateTime(
        date.year,
        date.month,
        date.day - (date.weekday - weekStartDay) % DateTime.daysPerWeek,
      ),
      PlanPeriod.month => DateTime(date.year, date.month),
      PlanPeriod.year => DateTime(date.year),
    };
  }

  /// Start of the period [count] periods after the one containing [date].
  DateTime shift(DateTime date, int count) {
    final start = startOf(date);
    return switch (this) {
      PlanPeriod.day => DateTime(start.year, start.month, start.day + count),
      PlanPeriod.week => DateTime(
        start.year,
        start.month,
        start.day + count * DateTime.daysPerWeek,
      ),
      PlanPeriod.month => DateTime(start.year, start.month + count),
      PlanPeriod.year => DateTime(start.year + count),
    };
  }

  /// Last day of the period containing [date].
  DateTime endOf(DateTime date) {
    final next = shift(date, 1);
    return DateTime(next.year, next.month, next.day - 1);
  }

  bool contains(DateTime periodDate, DateTime date) {
    return startOf(periodDate) == startOf(date);
  }

  /// Starts of every period overlapping [from]…[to] (inclusive days).
  List<DateTime> startsBetween(DateTime from, DateTime to) {
    final last = DateTime(to.year, to.month, to.day);
    final starts = <DateTime>[];
    for (
      var start = startOf(from);
      !start.isAfter(last);
      start = shift(start, 1)
    ) {
      starts.add(start);
    }
    return starts;
  }

  /// Smaller period a view of this period breaks into (week → days, …).
  PlanPeriod? get breakdown => switch (this) {
    PlanPeriod.day => null,
    PlanPeriod.week => PlanPeriod.day,
    PlanPeriod.month => PlanPeriod.week,
    PlanPeriod.year => PlanPeriod.month,
  };

  /// How many repetitions a new habit plans for by default.
  int get defaultHabitSpan => switch (this) {
    PlanPeriod.day => 30,
    PlanPeriod.week => 12,
    PlanPeriod.month => 12,
    PlanPeriod.year => 3,
  };

  /// Default last day for a habit repeating every period from [start].
  DateTime defaultHabitEnd(DateTime start) {
    final next = shift(start, defaultHabitSpan);
    return DateTime(next.year, next.month, next.day - 1);
  }
}
