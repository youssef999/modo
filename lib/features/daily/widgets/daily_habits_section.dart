import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';
import 'package:life_daily_app/features/goals/models/goal_tracker.dart';

class DailyHabitsSection extends StatelessWidget {
  const DailyHabitsSection({
    super.key,
    required this.selectedDate,
    required this.habits,
    required this.controller,
  });

  final DateTime selectedDate;
  final List<GoalModel> habits;
  final GoalsController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: colors.info.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                Icons.repeat_rounded,
                size: AppIconSize.sm,
                color: colors.info,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              LocaleKeys.todayHabits.tr,
              style: AppTextStyles.h6(
                colors,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colors.border.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                '${habits.length}',
                style: AppTextStyles.caption(
                  colors,
                ).copyWith(fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Habits List or Empty State
        if (habits.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: colors.border.withValues(alpha: 0.5)),
            ),
            child: Center(
              child: Text(
                LocaleKeys.noHabitsToday.tr,
                style: AppTextStyles.body2(
                  colors,
                ).copyWith(color: colors.textSecondary),
              ),
            ),
          )
        else
          ...habits.map((habit) {
            final isDone = controller.isHabitDoneForDate(habit, selectedDate);
            final numericTracker = habit.trackers
                .where((t) => t.kind == GoalTrackerKind.numeric)
                .firstOrNull;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _HabitCard(
                habit: habit,
                isDone: isDone,
                numericTracker: numericTracker,
                onToggle: () =>
                    controller.toggleHabitForDate(habit, selectedDate),
                onStepTracker: (increment) {
                  if (numericTracker != null) {
                    controller.stepTracker(habit, numericTracker.id, increment);
                  }
                },
              ),
            );
          }),
      ],
    );
  }
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({
    required this.habit,
    required this.isDone,
    this.numericTracker,
    required this.onToggle,
    required this.onStepTracker,
  });

  final GoalModel habit;
  final bool isDone;
  final GoalTracker? numericTracker;
  final VoidCallback onToggle;
  final ValueChanged<bool> onStepTracker;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDone
              ? colors.success.withValues(alpha: 0.35)
              : colors.border.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        children: [
          // Check-in Circle
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? colors.success : Colors.transparent,
                border: Border.all(
                  color: isDone
                      ? colors.success
                      : colors.textSecondary.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: isDone
                  ? Icon(
                      Icons.check_rounded,
                      size: AppIconSize.sm,
                      color: colors.onPrimary,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Habit Title & Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  habit.title,
                  style: AppTextStyles.body1(colors).copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? colors.textDisabled : colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      LocaleKeys.habitEveryDay.tr,
                      style: AppTextStyles.caption(
                        colors,
                      ).copyWith(color: colors.textSecondary, fontSize: 12),
                    ),
                    if (habit.checkIns.isNotEmpty) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '•  🔥 ${habit.checkIns.length}',
                        style: AppTextStyles.caption(colors).copyWith(
                          color: colors.warning,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Numeric Stepper ([-] [count] [+])
          if (numericTracker != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: colors.border.withValues(alpha: 0.8)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StepButton(
                    icon: Icons.remove_rounded,
                    onTap: () => onStepTracker(false),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    child: Text(
                      '${numericTracker!.current.toInt()} / ${numericTracker!.target.toInt()} ${numericTracker!.unit}',
                      style: AppTextStyles.caption(
                        colors,
                      ).copyWith(fontWeight: FontWeight.w700, fontSize: 11),
                    ),
                  ),
                  _StepButton(
                    icon: Icons.add_rounded,
                    onTap: () => onStepTracker(true),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(shape: BoxShape.circle, color: colors.card),
        child: Icon(icon, size: 16, color: colors.textPrimary),
      ),
    );
  }
}
