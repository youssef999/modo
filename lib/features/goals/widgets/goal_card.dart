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
import 'package:life_daily_app/features/goals/widgets/app_priority_picker.dart';
import 'package:life_daily_app/features/goals/widgets/app_status_picker.dart';
import 'package:life_daily_app/features/goals/widgets/goal_check_in_strip.dart';
import 'package:life_daily_app/features/goals/widgets/goal_success_indicator.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';
import 'package:life_daily_app/shared/widgets/feedback/app_confirm_dialog.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.goal});

  final GoalModel goal;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final controller = Get.find<GoalsController>();
    final category = controller.categoryById(goal.category);
    final categoryColor = category?.color(colors) ?? colors.primary;
    final dates = MaterialLocalizations.of(context);
    final dateLabel = goal.isHabit
        ? LocaleKeys.goalDateRange.trParams({
            'start': dates.formatMediumDate(goal.rangeStart),
            'end': dates.formatMediumDate(goal.rangeEnd),
          })
        : dates.formatMediumDate(goal.dueAt);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  category?.icon ?? Icons.flag_outlined,
                  size: AppIconSize.md,
                  color: categoryColor,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: InkWell(
                  onTap: () => AppNavigator.toGoalDetail(goal.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: AppTextStyles.h6(colors).copyWith(
                          decoration: goal.isFullyComplete
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          Text(
                            controller.goalCategoryLabel(goal),
                            style: AppTextStyles.caption(colors),
                          ),
                          GoalPriorityBadge(
                            priority: goal.priority,
                            onChanged: (newPriority) => controller
                                .changeGoalPriority(goal, newPriority),
                            compact: true,
                          ),
                          GoalStatusBadge(
                            status: goal.status,
                            onChanged: (newStatus) =>
                                controller.changeGoalStatus(goal, newStatus),
                            compact: true,
                          ),
                          GoalSuccessIndicator(goal: goal, compact: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _confirmDelete(context),
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: AppIconSize.md,
                  color: colors.textSecondary,
                ),
              ),
              IconButton(
                onPressed: () => AppNavigator.toGoalEditor(goal: goal),
                icon: Icon(
                  Icons.edit_outlined,
                  size: AppIconSize.md,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          if (goal.details.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(goal.details, style: AppTextStyles.body2(colors)),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.event_outlined,
                size: AppIconSize.sm,
                color: colors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(dateLabel, style: AppTextStyles.caption(colors)),
              ),
              if (!goal.isHabit)
                TextButton(
                  onPressed: () => Get.find<GoalsController>().toggleDone(goal),
                  child: Text(
                    goal.isDone
                        ? LocaleKeys.reopenGoal.tr
                        : LocaleKeys.completeGoal.tr,
                    style: AppTextStyles.caption(colors).copyWith(
                      color: goal.isDone
                          ? colors.textSecondary
                          : colors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (goal.isHabit) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: LinearProgressIndicator(
                      value: goal.progress,
                      minHeight: AppSpacing.xs,
                      color: colors.primary,
                      backgroundColor: colors.border,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${goal.progressPercent}%',
                  style: AppTextStyles.caption(colors).copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              LocaleKeys.goalCheckIns.trParams({
                'done': '${goal.completedDays}',
                'total': '${goal.plannedDays}',
              }),
              style: AppTextStyles.caption(colors),
            ),
            const SizedBox(height: AppSpacing.sm),
            GoalCheckInStrip(goal: goal),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => _logDay(context),
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
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await AppConfirmDialog.show(
      title: LocaleKeys.confirmDeleteTitle.tr,
      message: LocaleKeys.confirmDeleteGoal.tr,
    );
    if (!ok) return;
    await Get.find<GoalsController>().deleteGoal(goal);
  }

  Future<void> _logDay(BuildContext context) async {
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
    await Get.find<GoalsController>().logCheckIn(goal, picked);
  }
}
