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
import 'package:life_daily_app/shared/widgets/inputs/app_text_field.dart';

/// Checklist items inside a task, with inline add.
class TaskChecklist extends StatefulWidget {
  const TaskChecklist({
    super.key,
    required this.goal,
    required this.task,
    required this.controller,
  });

  final GoalModel goal;
  final GoalTask task;
  final GoalsController controller;

  @override
  State<TaskChecklist> createState() => _TaskChecklistState();
}

class _TaskChecklistState extends State<TaskChecklist> {
  final _input = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final title = _input.text.trim();
    if (title.isEmpty) return;
    _input.clear();
    await widget.controller.addSubtask(widget.goal, widget.task.id, title);
    if (mounted) _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in widget.task.subtasks)
          InkWell(
            onTap: () => widget.controller.toggleSubtask(
              widget.goal,
              widget.task.id,
              item.id,
            ),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs / 2),
              child: Row(
                children: [
                  Icon(
                    item.isCompleted
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    size: AppIconSize.sm,
                    color: item.isCompleted
                        ? colors.success
                        : colors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      item.title,
                      style: AppTextStyles.caption(colors).copyWith(
                        decoration: item.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: item.isCompleted
                            ? colors.textDisabled
                            : colors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => widget.controller.deleteSubtask(
                      widget.goal,
                      widget.task.id,
                      item.id,
                    ),
                    visualDensity: VisualDensity.compact,
                    tooltip: LocaleKeys.delete.tr,
                    icon: Icon(
                      Icons.close_rounded,
                      size: AppIconSize.xs,
                      color: colors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _input,
                focusNode: _focus,
                label: LocaleKeys.addChecklistItem.tr,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _add(),
              ),
            ),
            IconButton(
              onPressed: _add,
              tooltip: LocaleKeys.addChecklistItem.tr,
              icon: Icon(
                Icons.add_rounded,
                size: AppIconSize.md,
                color: colors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
