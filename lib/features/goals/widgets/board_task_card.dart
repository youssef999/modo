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
import 'package:life_daily_app/features/goals/widgets/app_priority_picker.dart';
import 'package:life_daily_app/features/goals/widgets/app_status_picker.dart';
import 'package:life_daily_app/features/goals/widgets/board_chip.dart';
import 'package:life_daily_app/features/goals/widgets/task_checklist.dart';

/// A standalone task card on the unified board.
class BoardTaskCard extends StatefulWidget {
  const BoardTaskCard({
    super.key,
    required this.goal,
    required this.task,
    required this.controller,
  });

  final GoalModel goal;
  final GoalTask task;
  final GoalsController controller;

  @override
  State<BoardTaskCard> createState() => _BoardTaskCardState();
}

class _BoardTaskCardState extends State<BoardTaskCard> {
  bool _showChecklist = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final goal = widget.goal;
    final task = widget.task;
    final controller = widget.controller;
    final items = task.subtasks;
    final isDone = task.isCompleted;
    final sectionId = controller.taskSectionId(goal, task);
    final section = sectionId == null
        ? null
        : controller.categoryById(sectionId);
    final due = task.dueDate;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDone
              ? colors.success.withValues(alpha: 0.3)
              : colors.border.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.04),
            blurRadius: AppSpacing.sm,
            offset: const Offset(0, AppSpacing.xs / 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => controller.toggleTask(goal, task.id),
                  customBorder: const CircleBorder(),
                  child: Icon(
                    isDone
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: AppIconSize.md,
                    color: isDone ? colors.success : colors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    task.title,
                    style: AppTextStyles.body2(colors).copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? colors.textDisabled : colors.textPrimary,
                    ),
                  ),
                ),
                TaskPriorityBadge(
                  priority: task.priority,
                  compact: true,
                  onChanged: (p) =>
                      controller.changeTaskPriority(goal, task.id, p),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (section != null)
                  BoardChip(
                    label: controller.categoryLabel(section),
                    icon: section.icon,
                    tone: section.color(colors),
                  ),
                if (due != null)
                  BoardChip(
                    label: '${due.day}/${due.month}',
                    icon: Icons.calendar_today_rounded,
                    tone: colors.textSecondary,
                  ),
                if (task.assigneeName?.isNotEmpty ?? false)
                  BoardChip(
                    label: task.assigneeName!,
                    icon: Icons.person_rounded,
                    tone: colors.primary,
                  ),
                TaskStatusBadge(
                  status: task.status,
                  compact: true,
                  onChanged: (next) =>
                      controller.changeTaskStatus(goal, task.id, next),
                ),
                InkWell(
                  onTap: () => setState(() => _showChecklist = !_showChecklist),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  child: BoardChip(
                    label: items.isEmpty
                        ? LocaleKeys.checklist.tr
                        : '${items.length}',
                    icon: Icons.checklist_rounded,
                    tone: _showChecklist
                        ? colors.primary
                        : colors.textSecondary,
                  ),
                ),
              ],
            ),
            if (_showChecklist) ...[
              const SizedBox(height: AppSpacing.xs),
              TaskChecklist(goal: goal, task: task, controller: controller),
            ],
          ],
        ),
      ),
    );
  }
}
