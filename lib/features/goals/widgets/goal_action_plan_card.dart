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
import 'package:life_daily_app/features/goals/models/goal_task.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';

class GoalActionPlanCard extends StatefulWidget {
  const GoalActionPlanCard({super.key, required this.goal});

  final GoalModel goal;

  @override
  State<GoalActionPlanCard> createState() => _GoalActionPlanCardState();
}

class _GoalActionPlanCardState extends State<GoalActionPlanCard> {
  final _taskInputController = TextEditingController();
  bool _isAdding = false;

  @override
  void dispose() {
    _taskInputController.dispose();
    super.dispose();
  }

  void _submitTask() {
    final title = _taskInputController.text.trim();
    if (title.isNotEmpty) {
      Get.find<GoalsController>().addTask(widget.goal, title);
      _taskInputController.clear();
      setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final controller = Get.find<GoalsController>();
    final currentGoal = controller.goalById(widget.goal.id) ?? widget.goal;
    final tasks = currentGoal.tasks;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.checklist_rounded,
                  size: AppIconSize.md,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.actionPlan.tr,
                      style: AppTextStyles.h6(colors),
                    ),
                    Text(
                      LocaleKeys.actionPlanSubtitle.tr,
                      style: AppTextStyles.caption(colors),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _isAdding = !_isAdding),
                icon: Icon(
                  _isAdding ? Icons.close_rounded : Icons.add_rounded,
                  color: colors.primary,
                  size: AppIconSize.md,
                ),
                tooltip: LocaleKeys.addTask.tr,
              ),
            ],
          ),
          if (_isAdding) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskInputController,
                    autofocus: true,
                    style: AppTextStyles.body2(colors),
                    decoration: InputDecoration(
                      hintText: LocaleKeys.taskTitle.tr,
                      hintStyle: AppTextStyles.caption(colors),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.sm,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        borderSide: BorderSide(color: colors.primary),
                      ),
                    ),
                    onSubmitted: (_) => _submitTask(),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                IconButton(
                  onPressed: _submitTask,
                  icon: Icon(
                    Icons.check_rounded,
                    color: colors.success,
                    size: AppIconSize.md,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          if (tasks.isEmpty && !_isAdding)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Center(
                child: Text(
                  LocaleKeys.noTasksYet.tr,
                  style: AppTextStyles.caption(colors),
                ),
              ),
            )
          else
            Column(
              children: [
                for (final task in tasks)
                  _TaskItemTile(
                    task: task,
                    onToggle: () => controller.toggleTask(currentGoal, task.id),
                    onDelete: () => controller.deleteTask(currentGoal, task.id),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TaskItemTile extends StatelessWidget {
  const _TaskItemTile({
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  final GoalTask task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: task.isCompleted
                ? colors.border.withValues(alpha: 0.5)
                : colors.border,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Icon(
                    task.isCompleted
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    color: task.isCompleted
                        ? colors.success
                        : colors.textSecondary,
                    size: AppIconSize.md,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  task.title,
                  style: AppTextStyles.body2(colors).copyWith(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: task.isCompleted
                        ? colors.textSecondary
                        : colors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: AppIconSize.sm,
                  color: colors.textSecondary.withValues(alpha: 0.6),
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
