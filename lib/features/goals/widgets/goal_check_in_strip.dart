import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';

class GoalCheckInStrip extends StatelessWidget {
  const GoalCheckInStrip({super.key, required this.goal});

  final GoalModel goal;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final days = goal.recentDays();
    final labels = MaterialLocalizations.of(context);
    return Row(
      children: days.map((day) {
        final checked = goal.isChecked(day);
        final enabled = goal.canLog(day);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs / 2),
            child: Column(
              children: [
                Text(
                  labels.narrowWeekdays[day.weekday % 7],
                  style: AppTextStyles.caption(colors),
                ),
                const SizedBox(height: AppSpacing.xs),
                InkWell(
                  onTap: enabled
                      ? () =>
                            Get.find<GoalsController>().toggleCheckIn(goal, day)
                      : null,
                  customBorder: const CircleBorder(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: AppSpacing.xl,
                    height: AppSpacing.xl,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: checked ? colors.primary : colors.surface,
                      border: Border.all(
                        color: checked ? colors.primary : colors.border,
                      ),
                    ),
                    child: Text(
                      '${day.day}',
                      style: AppTextStyles.caption(colors).copyWith(
                        color: checked
                            ? colors.onPrimary
                            : enabled
                            ? colors.textPrimary
                            : colors.textDisabled,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
