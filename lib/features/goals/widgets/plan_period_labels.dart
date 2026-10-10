import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/features/goals/models/plan_period.dart';

/// Localized names and date labels for plan periods.
class PlanPeriodLabels {
  PlanPeriodLabels._();

  static String get _locale => Get.locale?.languageCode ?? 'en';

  static String name(PlanPeriod period) => switch (period) {
    PlanPeriod.day => LocaleKeys.planDay.tr,
    PlanPeriod.week => LocaleKeys.planWeek.tr,
    PlanPeriod.month => LocaleKeys.planMonth.tr,
    PlanPeriod.year => LocaleKeys.planYear.tr,
  };

  static String repeat(PlanPeriod period) => switch (period) {
    PlanPeriod.day => LocaleKeys.repeatDaily.tr,
    PlanPeriod.week => LocaleKeys.repeatWeekly.tr,
    PlanPeriod.month => LocaleKeys.repeatMonthly.tr,
    PlanPeriod.year => LocaleKeys.repeatYearly.tr,
  };

  /// Heading of a period, e.g. "Sat 11 Oct", "11 – 17 Oct", "October 2026".
  static String range(PlanPeriod period, DateTime start) {
    return switch (period) {
      PlanPeriod.day => DateFormat('EEE d MMM', _locale).format(start),
      PlanPeriod.week => _weekRange(start),
      PlanPeriod.month => DateFormat.yMMMM(_locale).format(start),
      PlanPeriod.year => DateFormat.y(_locale).format(start),
    };
  }

  /// Short heading for a breakdown card ("Sat 11", "11 – 17 Oct", "Oct").
  static String short(PlanPeriod period, DateTime start) {
    return switch (period) {
      PlanPeriod.day => DateFormat('EEE d', _locale).format(start),
      PlanPeriod.week => _weekRange(start),
      PlanPeriod.month => DateFormat.MMMM(_locale).format(start),
      PlanPeriod.year => DateFormat.y(_locale).format(start),
    };
  }

  /// Small label above a tracker cell (weekday, month, year).
  static String cellTop(PlanPeriod period, DateTime start) {
    return switch (period) {
      PlanPeriod.day => DateFormat.E(_locale).format(start),
      PlanPeriod.week => DateFormat.MMM(_locale).format(start),
      PlanPeriod.month => DateFormat.y(_locale).format(start),
      PlanPeriod.year => '',
    };
  }

  /// Main label of a tracker cell (day number, month number, year).
  static String cellMain(PlanPeriod period, DateTime start) {
    return switch (period) {
      PlanPeriod.day || PlanPeriod.week => '${start.day}',
      PlanPeriod.month => '${start.month}',
      PlanPeriod.year => '${start.year}',
    };
  }

  static String _weekRange(DateTime start) {
    final end = PlanPeriod.week.endOf(start);
    final day = DateFormat.d(_locale);
    final dayMonth = DateFormat('d MMM', _locale);
    final from = start.month == end.month
        ? day.format(start)
        : dayMonth.format(start);
    return '$from – ${dayMonth.format(end)}';
  }
}
