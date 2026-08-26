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
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';
import 'package:life_daily_app/shared/widgets/feedback/app_confirm_dialog.dart';

class GoalGridCard extends StatelessWidget {
  const GoalGridCard({super.key, required this.goal});

  final GoalModel goal;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final controller = Get.find<GoalsController>();
    final category = controller.categoryById(goal.category);
    final categoryColor = category?.color(colors) ?? colors.primary;
    final dates = MaterialLocalizations.of(context);
    final dateLabel = goal.isHabit
        ? '${goal.progressPercent}%'
        : dates.formatMediumDate(goal.dueAt);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
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
              const Spacer(),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _confirmDelete,
                icon: Icon(
                  Icons.close_rounded,
                  size: AppIconSize.sm,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: GestureDetector(
              onTap: () => AppNavigator.toGoalEditor(goal: goal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h6(colors).copyWith(
                      decoration: goal.isFullyComplete
                          ? TextDecoration.lineThrough
                          : null,
                      color: goal.isFullyComplete
                          ? colors.textSecondary
                          : colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    controller.goalCategoryLabel(goal),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(colors),
                  ),
                  if (goal.details.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      goal.details,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body2(colors),
                    ),
                  ],
                  const Spacer(),
                  if (goal.isHabit) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: LinearProgressIndicator(
                        value: goal.progress,
                        minHeight: AppSpacing.xs,
                        color: colors.primary,
                        backgroundColor: colors.border,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      dateLabel,
                      style: AppTextStyles.caption(colors).copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final ok = await AppConfirmDialog.show(
      title: LocaleKeys.confirmDeleteTitle.tr,
      message: LocaleKeys.confirmDeleteGoal.tr,
    );
    if (!ok) return;
    await Get.find<GoalsController>().deleteGoal(goal);
  }
}
