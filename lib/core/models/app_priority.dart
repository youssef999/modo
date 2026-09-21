import 'package:life_daily_app/core/constants/locale_keys.dart';

enum AppPriority {
  urgent,
  high,
  medium,
  low,
  none;

  int get weight => switch (this) {
        AppPriority.urgent => 4,
        AppPriority.high => 3,
        AppPriority.medium => 2,
        AppPriority.low => 1,
        AppPriority.none => 0,
      };

  String get labelKey => switch (this) {
        AppPriority.urgent => LocaleKeys.priorityUrgent,
        AppPriority.high => LocaleKeys.priorityHigh,
        AppPriority.medium => LocaleKeys.priorityMedium,
        AppPriority.low => LocaleKeys.priorityLow,
        AppPriority.none => LocaleKeys.priorityNone,
      };

  bool get isUrgent => this == AppPriority.urgent;
  bool get isHigh => this == AppPriority.high;

  static AppPriority fromName(String? name) {
    if (name == null || name.isEmpty) return AppPriority.medium;
    return AppPriority.values.firstWhere(
      (p) => p.name.toLowerCase() == name.toLowerCase(),
      orElse: () => AppPriority.medium,
    );
  }
}
