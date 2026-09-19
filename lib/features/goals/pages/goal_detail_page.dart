import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';
import 'package:life_daily_app/features/goals/widgets/dynamic_tracker_widget.dart';
import 'package:life_daily_app/features/goals/widgets/goal_action_plan_card.dart';
import 'package:life_daily_app/features/goals/widgets/goal_check_in_strip.dart';
import 'package:life_daily_app/features/goals/widgets/goal_success_indicator.dart';
import 'package:life_daily_app/shared/widgets/feedback/app_confirm_dialog.dart';
import 'package:life_daily_app/shared/widgets/layout/app_scaffold.dart';

class GoalDetailPage extends StatelessWidget {
  const GoalDetailPage({super.key, required this.goalId});

  final String goalId;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return GetBuilder<GoalsController>(
      id: 'goals',
      builder: (controller) {
        final goal = controller.goalById(goalId);
        if (goal == null) {
          return AppScaffold(
            title: LocaleKeys.goalDetailTitle.tr,
            body: Center(
              child: Text(
                LocaleKeys.goalsEmptyTitle.tr,
                style: AppTextStyles.body1(colors),
              ),
            ),
          );
        }

        final category = controller.categoryById(goal.category);
        final categoryColor = category?.color(colors) ?? colors.primary;
        final dates = MaterialLocalizations.of(context);
        final dateLabel = goal.isHabit
            ? LocaleKeys.goalDateRange.trParams({
                'start': dates.formatMediumDate(goal.rangeStart),
                'end': dates.formatMediumDate(goal.rangeEnd),
              })
            : dates.formatMediumDate(goal.dueAt);

        return AppScaffold(
          title: goal.title,
          actions: [
            IconButton(
              onPressed: () => AppNavigator.toGoalEditor(goal: goal),
              icon: Icon(
                Icons.edit_outlined,
                size: AppIconSize.md,
                color: colors.textSecondary,
              ),
            ),
            IconButton(
              onPressed: () => _confirmDelete(context, controller, goal),
              icon: Icon(
                Icons.delete_outline_rounded,
                size: AppIconSize.md,
                color: colors.error,
              ),
            ),
          ],
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        category?.icon ?? Icons.flag_outlined,
                        size: AppIconSize.lg,
                        color: categoryColor,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            style: AppTextStyles.h5(colors).copyWith(
                              decoration: goal.isFullyComplete
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                controller.goalCategoryLabel(goal),
                                style: AppTextStyles.caption(colors).copyWith(
                                  color: categoryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text('•', style: AppTextStyles.caption(colors)),
                              const SizedBox(width: AppSpacing.sm),
                              Text(dateLabel,
                                  style: AppTextStyles.caption(colors)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (goal.details.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(goal.details, style: AppTextStyles.body2(colors)),
                ],
                const SizedBox(height: AppSpacing.lg),
                GoalSuccessIndicator(goal: goal),
                const SizedBox(height: AppSpacing.md),
                GoalActionPlanCard(goal: goal),
                const SizedBox(height: AppSpacing.md),
                DynamicTrackerWidget(goal: goal),
                if (goal.isHabit) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    LocaleKeys.goalCheckIns.trParams({
                      'done': '${goal.completedDays}',
                      'total': '${goal.plannedDays}',
                    }),
                    style: AppTextStyles.h6(colors),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GoalCheckInStrip(goal: goal),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () => _logDay(context, controller, goal),
                      child: Text(
                        LocaleKeys.goalLogDay.tr,
                        style: AppTextStyles.caption(colors).copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    GoalsController controller,
    GoalModel goal,
  ) async {
    final ok = await AppConfirmDialog.show(
      title: LocaleKeys.confirmDeleteTitle.tr,
      message: LocaleKeys.confirmDeleteGoal.tr,
    );
    if (!ok) return;
    await controller.deleteGoal(goal);
    AppNavigator.back();
  }

  Future<void> _logDay(
    BuildContext context,
    GoalsController controller,
    GoalModel goal,
  ) async {
    final today = GoalModel.dateOnly(DateTime.now());
    final lastAllowed = today.isBefore(goal.rangeEnd) ? today : goal.rangeEnd;
    if (lastAllowed.isBefore(goal.rangeStart)) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: lastAllowed,
      firstDate: goal.rangeStart,
      lastDate: lastAllowed,
    );
    if (picked == null) return;
    await controller.logCheckIn(goal, picked);
  }
}
