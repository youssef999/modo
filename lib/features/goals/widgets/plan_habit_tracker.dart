import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/models/plan_period.dart';
import 'package:life_daily_app/features/goals/models/plan_snapshot.dart';
import 'package:life_daily_app/features/goals/widgets/plan_habit_grid.dart';
import 'package:life_daily_app/features/goals/widgets/plan_section_header.dart';
import 'package:life_daily_app/features/goals/widgets/plan_period_labels.dart';
import 'package:life_daily_app/features/shell/widgets/quick_add_sheet.dart';

/// Habit check grid for the viewed period, one block per repeat.
class PlanHabitTracker extends StatelessWidget {
  const PlanHabitTracker({
    super.key,
    required this.snapshot,
    required this.controller,
    this.addRepeat,
  });

  final PlanSnapshot snapshot;
  final GoalsController controller;

  /// How often a habit added from here repeats; the viewed period if null.
  final PlanPeriod? addRepeat;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final count = snapshot.habitGroups.fold<int>(
      0,
      (sum, group) => sum + group.rows.length,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PlanSectionHeader(
              icon: Icons.repeat_rounded,
              tone: colors.info,
              title: LocaleKeys.planHabitTracker.tr,
              count: count,
              addTooltip: LocaleKeys.planAddHabit.tr,
              onAdd: () => QuickAddSheet.show(
                context,
                period: addRepeat ?? snapshot.period,
                repeat: true,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (snapshot.habitGroups.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  LocaleKeys.planNoHabits.tr,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body2(
                    colors,
                  ).copyWith(color: colors.textSecondary),
                ),
              )
            else
              for (final group in snapshot.habitGroups) ...[
                if (snapshot.habitGroups.length > 1 ||
                    group.repeat != snapshot.period.breakdown)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.sm,
                      bottom: AppSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.event_repeat_rounded,
                          size: AppIconSize.sm,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          PlanPeriodLabels.repeat(group.repeat),
                          style: AppTextStyles.caption(colors).copyWith(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                PlanHabitGrid(
                  group: group,
                  onToggle: (habit, start) =>
                      controller.toggleCheckIn(habit, start),
                ),
              ],
          ],
        ),
      ),
    );
  }
}
