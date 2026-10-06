import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';

class DailyDateStrip extends StatelessWidget {
  const DailyDateStrip({
    super.key,
    required this.selectedDate,
    required this.onSelectDate,
    required this.completedCount,
    required this.totalCount,
    required this.progress,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;
  final int completedCount;
  final int totalCount;
  final double progress;

  List<DateTime> _getWeekDays(DateTime baseDate) {
    // Generate 7 days centered or starting around baseDate
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Show 3 days before today, today, and 3 days after today
    return List.generate(7, (i) => today.add(Duration(days: i - 3)));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final weekDays = _getWeekDays(selectedDate);
    final now = DateTime.now();
    final isArabic = Get.locale?.languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Focus title & Progress
          Row(
            children: [
              Expanded(
                child: Text(
                  LocaleKeys.todayTitle.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h6(
                    colors,
                  ).copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.2),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  LocaleKeys.todayHabitsTasksCount.trParams({
                    'completed': '$completedCount',
                    'total': '$totalCount',
                  }),
                  style: AppTextStyles.caption(colors).copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs + 2),

          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: colors.border.withValues(alpha: 0.4),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? colors.success : colors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Date Pills Strip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays.map((date) {
              final isSelected = _isSameDay(date, selectedDate);
              final isToday = _isSameDay(date, now);
              final dayName = DateFormat(
                'E',
                isArabic ? 'ar' : 'en',
              ).format(date);
              final dayNumber = date.day.toString();

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    onTap: () => onSelectDate(date),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs + 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primary
                            : (isToday
                                  ? colors.primary.withValues(alpha: 0.08)
                                  : Colors.transparent),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : (isToday
                                    ? colors.primary.withValues(alpha: 0.3)
                                    : Colors.transparent),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            dayName,
                            style: AppTextStyles.caption(colors).copyWith(
                              fontSize: 11,
                              color: isSelected
                                  ? colors.onPrimary
                                  : colors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dayNumber,
                            style: AppTextStyles.body2(colors).copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected
                                  ? colors.onPrimary
                                  : colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? colors.onPrimary
                                  : Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
