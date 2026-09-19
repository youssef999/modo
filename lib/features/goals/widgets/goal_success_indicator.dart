import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';

class GoalSuccessIndicator extends StatelessWidget {
  const GoalSuccessIndicator({
    super.key,
    required this.goal,
    this.compact = false,
  });

  final GoalModel goal;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final percent = goal.overallSuccessPercent;
    final successRate = goal.overallSuccessRate;

    final progressColor = percent >= 100
        ? colors.success
        : percent >= 50
            ? colors.primary
            : colors.warning;

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: AppSpacing.lg,
            height: AppSpacing.lg,
            child: CircularProgressIndicator(
              value: successRate,
              strokeWidth: 3,
              backgroundColor: colors.border,
              color: progressColor,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$percent%',
            style: AppTextStyles.caption(colors).copyWith(
              color: progressColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocaleKeys.goalOverallProgress.tr,
                style: AppTextStyles.h6(colors),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '$percent%',
                  style: AppTextStyles.body2(colors).copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: successRate,
              minHeight: 10,
              backgroundColor: colors.surface,
              color: progressColor,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MetricItem(
                label: goal.isHabit
                    ? LocaleKeys.goalCheckIns.trParams({
                        'done': '${goal.completedDays}',
                        'total': '${goal.plannedDays}',
                      })
                    : (goal.isDone
                        ? LocaleKeys.completeGoal.tr
                        : LocaleKeys.goalsTitle.tr),
                value: '${goal.progressPercent}%',
                icon: Icons.check_circle_outline_rounded,
              ),
              if (goal.tasks.isNotEmpty)
                _MetricItem(
                  label: LocaleKeys.goalTasksProgress.tr,
                  value: '${goal.completedTasksCount}/${goal.tasks.length}',
                  icon: Icons.checklist_rounded,
                ),
              if (goal.trackers.isNotEmpty)
                _MetricItem(
                  label: LocaleKeys.trackers.tr,
                  value: '${goal.trackerProgressPercent}%',
                  icon: Icons.speed_rounded,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: colors.textSecondary),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.body2(colors).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption(colors),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
