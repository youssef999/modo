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
import 'package:life_daily_app/features/goals/models/goal_task.dart';
import 'package:life_daily_app/features/goals/widgets/app_priority_picker.dart';
import 'package:life_daily_app/features/goals/widgets/app_status_picker.dart';
import 'package:life_daily_app/features/goals/widgets/board_chip.dart';
import 'package:life_daily_app/features/goals/widgets/task_checklist.dart';
import 'package:life_daily_app/features/shell/widgets/quick_add_sheet.dart';

/// A big task (goal) on the unified board; expands to show its small tasks.
class BoardGoalCard extends StatefulWidget {
  const BoardGoalCard({
    super.key,
    required this.goal,
    required this.controller,
  });

  final GoalModel goal;
  final GoalsController controller;

  @override
  State<BoardGoalCard> createState() => _BoardGoalCardState();
}

class _BoardGoalCardState extends State<BoardGoalCard> {
  static const double _stripeWidth = 4;
  static const double _progressHeight = 4;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final goal = widget.goal;
    final controller = widget.controller;
    final category = controller.categoryById(goal.category);
    final tone = category?.color(colors) ?? colors.primary;
    final total = goal.tasks.length;
    final done = goal.completedTasksCount;
    final progress = goal.isHabit
        ? goal.progress
        : (total == 0 ? 0.0 : done / total);

    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(AppRadius.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => AppNavigator.toGoalDetail(goal.id),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: BorderDirectional(
              start: BorderSide(color: tone, width: _stripeWidth),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.flag_rounded, size: AppIconSize.sm, color: tone),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        goal.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body1(colors).copyWith(
                          fontWeight: FontWeight.w700,
                          decoration: goal.isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    GoalPriorityBadge(
                      priority: goal.priority,
                      compact: true,
                      onChanged: (p) => controller.changeGoalPriority(goal, p),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (category != null)
                      BoardChip(
                        label: controller.categoryLabel(category),
                        icon: category.icon,
                        tone: tone,
                      ),
                    GoalStatusBadge(
                      status: goal.status,
                      compact: true,
                      onChanged: (s) => controller.changeGoalStatus(goal, s),
                    ),
                  ],
                ),
                if (total > 0 || goal.isHabit) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _ProgressRow(
                    progress: progress,
                    label: goal.isHabit
                        ? '${(progress * 100).round()}%'
                        : '$done/$total',
                    tone: tone,
                    expanded: _expanded,
                    canExpand: true,
                    onToggle: () => setState(() => _expanded = !_expanded),
                  ),
                ] else
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: _ExpandButton(
                      expanded: _expanded,
                      onTap: () => setState(() => _expanded = !_expanded),
                    ),
                  ),
                if (_expanded) _Subtasks(goal: goal, controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.progress,
    required this.label,
    required this.tone,
    required this.expanded,
    required this.canExpand,
    required this.onToggle,
  });

  final double progress;
  final String label;
  final Color tone;
  final bool expanded;
  final bool canExpand;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: _BoardGoalCardState._progressHeight,
              backgroundColor: colors.border,
              valueColor: AlwaysStoppedAnimation<Color>(tone),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTextStyles.caption(
            colors,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
        if (canExpand) _ExpandButton(expanded: expanded, onTap: onToggle),
      ],
    );
  }
}

class _ExpandButton extends StatelessWidget {
  const _ExpandButton({required this.expanded, required this.onTap});

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return IconButton(
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      tooltip: LocaleKeys.navTasks.tr,
      icon: AnimatedRotation(
        turns: expanded ? 0.5 : 0,
        duration: const Duration(milliseconds: 180),
        child: Icon(
          Icons.expand_more_rounded,
          size: AppIconSize.md,
          color: colors.textSecondary,
        ),
      ),
    );
  }
}

class _SubtaskRow extends StatefulWidget {
  const _SubtaskRow({
    super.key,
    required this.goal,
    required this.task,
    required this.controller,
  });

  final GoalModel goal;
  final GoalTask task;
  final GoalsController controller;

  @override
  State<_SubtaskRow> createState() => _SubtaskRowState();
}

class _SubtaskRowState extends State<_SubtaskRow> {
  bool _showChecklist = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final task = widget.task;
    final items = task.subtasks;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => widget.controller.toggleTask(widget.goal, task.id),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs / 2),
            child: Row(
              children: [
                Icon(
                  task.isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: AppIconSize.sm,
                  color: task.isCompleted
                      ? colors.success
                      : colors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body2(colors).copyWith(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.isCompleted
                          ? colors.textDisabled
                          : colors.textPrimary,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      setState(() => _showChecklist = !_showChecklist),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: _showChecklist
                        ? colors.primary
                        : colors.textSecondary,
                  ),
                  icon: const Icon(
                    Icons.checklist_rounded,
                    size: AppIconSize.sm,
                  ),
                  label: Text(
                    items.isEmpty
                        ? ''
                        : '${task.subtasksCompletedCount}/${items.length}',
                    style: AppTextStyles.caption(colors).copyWith(
                      color: _showChecklist
                          ? colors.primary
                          : colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showChecklist)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: AppSpacing.lg),
            child: TaskChecklist(
              goal: widget.goal,
              task: task,
              controller: widget.controller,
            ),
          ),
      ],
    );
  }
}

class _Subtasks extends StatelessWidget {
  const _Subtasks({required this.goal, required this.controller});

  final GoalModel goal;
  final GoalsController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final task in goal.tasks)
            _SubtaskRow(
              key: ValueKey(task.id),
              goal: goal,
              task: task,
              controller: controller,
            ),
          TextButton.icon(
            onPressed: () => QuickAddSheet.show(context, goalId: goal.id),
            style: TextButton.styleFrom(
              alignment: AlignmentDirectional.centerStart,
              foregroundColor: colors.primary,
            ),
            icon: const Icon(Icons.add_rounded, size: AppIconSize.sm),
            label: Text(
              LocaleKeys.addTask.tr,
              style: AppTextStyles.caption(
                colors,
              ).copyWith(color: colors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
