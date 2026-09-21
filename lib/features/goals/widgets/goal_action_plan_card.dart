import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/models/app_priority.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/models/goal_member.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';
import 'package:life_daily_app/features/goals/models/goal_task.dart';
import 'package:life_daily_app/features/goals/widgets/app_priority_picker.dart';
import 'package:life_daily_app/features/goals/widgets/app_status_picker.dart';
import 'package:life_daily_app/features/goals/widgets/goal_members_sheet.dart';
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
  GoalTaskStatus _selectedTaskStatus = GoalTaskStatus.todo;
  AppPriority _selectedPriority = AppPriority.medium;
  GoalMember? _selectedAssignee;

  @override
  void dispose() {
    _taskInputController.dispose();
    super.dispose();
  }

  void _submitTask() {
    final title = _taskInputController.text.trim();
    if (title.isNotEmpty) {
      Get.find<GoalsController>().addTask(
        widget.goal,
        title,
        status: _selectedTaskStatus,
        priority: _selectedPriority,
        assigneeId: _selectedAssignee?.uid,
        assigneeEmail: _selectedAssignee?.email,
        assigneeName: _selectedAssignee?.displayName,
      );
      _taskInputController.clear();
      setState(() {
        _isAdding = false;
        _selectedTaskStatus = GoalTaskStatus.todo;
        _selectedPriority = AppPriority.medium;
        _selectedAssignee = null;
      });
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
                      '${currentGoal.completedTasksCount}/${tasks.length} ${LocaleKeys.tasksCount.tr} (${currentGoal.taskCompletionPercent}%)',
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
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      TaskPriorityBadge(
                        priority: _selectedPriority,
                        onChanged: (p) => setState(() => _selectedPriority = p),
                      ),
                      TaskStatusBadge(
                        status: _selectedTaskStatus,
                        onChanged: (s) => setState(() => _selectedTaskStatus = s),
                      ),
                      if (currentGoal.members.isNotEmpty)
                        _AssigneePickerBadge(
                          members: currentGoal.members,
                          selectedMember: _selectedAssignee,
                          onChanged: (m) => setState(() => _selectedAssignee = m),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
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
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: AppSpacing.sm,
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
              ),
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
                    members: currentGoal.members,
                    onToggle: () => controller.toggleTask(currentGoal, task.id),
                    onDelete: () => controller.deleteTask(currentGoal, task.id),
                    onStatusChanged: (newStatus) => controller.changeTaskStatus(
                      currentGoal,
                      task.id,
                      newStatus,
                    ),
                    onPriorityChanged: (newPriority) =>
                        controller.changeTaskPriority(
                      currentGoal,
                      task.id,
                      newPriority,
                    ),
                    onAssign: () => _showAssignMemberDialog(
                      context,
                      controller,
                      currentGoal,
                      task,
                    ),
                    onReassignGoal: () => _showReassignGoalDialog(
                      context,
                      controller,
                      currentGoal,
                      task,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _showAssignMemberDialog(
    BuildContext context,
    GoalsController controller,
    GoalModel currentGoal,
    GoalTask task,
  ) async {
    final colors = context.appPalette;
    final members = currentGoal.members;

    final chosen = await showDialog<GoalMember?>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            Icon(
              Icons.person_add_alt_1_outlined,
              color: colors.primary,
              size: AppIconSize.md,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(LocaleKeys.assignTo.tr, style: AppTextStyles.h6(colors)),
          ],
        ),
        content: SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: colors.border,
                  child: Icon(Icons.person_off_outlined, size: 16, color: colors.textSecondary),
                ),
                title: Text(LocaleKeys.unassigned.tr, style: AppTextStyles.body2(colors)),
                trailing: task.assigneeId == null
                    ? Icon(Icons.check_rounded, color: colors.primary, size: 18)
                    : null,
                onTap: () => Navigator.of(ctx).pop(null),
              ),
              const Divider(height: 1),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: members.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, index) {
                    final m = members[index];
                    final isSelected = task.assigneeId == m.uid;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: colors.primary.withValues(alpha: 0.15),
                        child: Text(
                          m.initials,
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      title: Text(
                        m.displayName.isNotEmpty ? m.displayName : m.email,
                        style: AppTextStyles.body2(colors),
                      ),
                      subtitle: Text(m.email, style: AppTextStyles.caption(colors)),
                      trailing: isSelected
                          ? Icon(Icons.check_rounded, color: colors.primary, size: 18)
                          : null,
                      onTap: () => Navigator.of(ctx).pop(m),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await controller.assignTask(
      goal: currentGoal,
      taskId: task.id,
      member: chosen,
    );
  }

  Future<void> _showReassignGoalDialog(
    BuildContext context,
    GoalsController controller,
    GoalModel currentGoal,
    GoalTask task,
  ) async {
    final otherGoals =
        controller.goals.where((g) => g.id != currentGoal.id).toList();
    final colors = context.appPalette;

    if (otherGoals.isEmpty) {
      Get.snackbar(
        LocaleKeys.reassignGoal.tr,
        'No other goals available to move this task to.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: colors.card,
        colorText: colors.textPrimary,
      );
      return;
    }

    final chosenGoal = await showDialog<GoalModel>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            Icon(
              Icons.drive_file_move_outlined,
              color: colors.primary,
              size: AppIconSize.md,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(LocaleKeys.reassignGoal.tr, style: AppTextStyles.h6(colors)),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.selectConnectedGoal.tr,
                style: AppTextStyles.caption(colors),
              ),
              const SizedBox(height: AppSpacing.md),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: otherGoals.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, index) {
                    final g = otherGoals[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      leading: Icon(
                        Icons.flag_outlined,
                        color: colors.primary,
                      ),
                      title: Text(g.title, style: AppTextStyles.body2(colors)),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                      ),
                      onTap: () => Navigator.of(ctx).pop(g),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (chosenGoal != null) {
      await controller.reassignTaskToGoal(
        fromGoalId: currentGoal.id,
        toGoalId: chosenGoal.id,
        taskId: task.id,
      );
    }
  }
}

class _TaskItemTile extends StatelessWidget {
  const _TaskItemTile({
    required this.task,
    required this.members,
    required this.onToggle,
    required this.onDelete,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onAssign,
    required this.onReassignGoal,
  });

  final GoalTask task;
  final List<GoalMember> members;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final ValueChanged<GoalTaskStatus> onStatusChanged;
  final ValueChanged<AppPriority> onPriorityChanged;
  final VoidCallback onAssign;
  final VoidCallback onReassignGoal;

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
              if (members.length > 1 || task.assigneeId != null) ...[
                const SizedBox(width: AppSpacing.xs),
                Tooltip(
                  message: task.assigneeId != null
                      ? (task.assigneeName?.isNotEmpty == true
                          ? '${task.assigneeName} (${task.assigneeEmail})'
                          : task.assigneeEmail ?? LocaleKeys.assignedTo.tr)
                      : LocaleKeys.assignTo.tr,
                  child: InkWell(
                    onTap: onAssign,
                    borderRadius: BorderRadius.circular(12),
                    child: task.assigneeId != null
                        ? AssigneeAvatar(
                            initials: task.assigneeInitials,
                            size: 22,
                          )
                        : Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.border,
                              ),
                            ),
                            child: Icon(
                              Icons.person_add_alt_1_outlined,
                              size: 13,
                              color: colors.textSecondary,
                            ),
                          ),
                  ),
                ),
              ],
              const SizedBox(width: AppSpacing.xs),
              TaskPriorityBadge(
                priority: task.priority,
                onChanged: onPriorityChanged,
                compact: true,
              ),
              const SizedBox(width: AppSpacing.xs),
              TaskStatusBadge(
                status: task.status,
                onChanged: onStatusChanged,
                compact: true,
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: AppIconSize.sm,
                  color: colors.textSecondary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onSelected: (action) {
                  if (action == 'assign') {
                    onAssign();
                  } else if (action == 'reassign') {
                    onReassignGoal();
                  } else if (action == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (ctx) => [
                  if (members.isNotEmpty)
                    PopupMenuItem<String>(
                      value: 'assign',
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_add_alt_1_outlined,
                            size: AppIconSize.sm,
                            color: colors.textPrimary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            LocaleKeys.assignTo.tr,
                            style: AppTextStyles.body2(colors),
                          ),
                        ],
                      ),
                    ),
                  PopupMenuItem<String>(
                    value: 'reassign',
                    child: Row(
                      children: [
                        Icon(
                          Icons.drive_file_move_outlined,
                          size: AppIconSize.sm,
                          color: colors.textPrimary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          LocaleKeys.reassignGoal.tr,
                          style: AppTextStyles.body2(colors),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: AppIconSize.sm,
                          color: colors.error,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          LocaleKeys.delete.tr,
                          style: AppTextStyles.body2(colors).copyWith(
                            color: colors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssigneePickerBadge extends StatelessWidget {
  const _AssigneePickerBadge({
    required this.members,
    required this.selectedMember,
    required this.onChanged,
  });

  final List<GoalMember> members;
  final GoalMember? selectedMember;
  final ValueChanged<GoalMember?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return PopupMenuButton<GoalMember?>(
      tooltip: LocaleKeys.selectAssignee.tr,
      onSelected: onChanged,
      itemBuilder: (ctx) => [
        PopupMenuItem<GoalMember?>(
          value: null,
          child: Row(
            children: [
              Icon(Icons.person_off_outlined, size: 16, color: colors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Text(LocaleKeys.unassigned.tr, style: AppTextStyles.body2(colors)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        ...members.map(
          (m) => PopupMenuItem<GoalMember?>(
            value: m,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: colors.primary.withValues(alpha: 0.15),
                  child: Text(
                    m.initials,
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  m.displayName.isNotEmpty ? m.displayName : m.email,
                  style: AppTextStyles.body2(colors),
                ),
              ],
            ),
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selectedMember != null
              ? colors.primary.withValues(alpha: 0.12)
              : colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: selectedMember != null
                ? colors.primary.withValues(alpha: 0.4)
                : colors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selectedMember != null
                  ? Icons.person_rounded
                  : Icons.person_add_alt_rounded,
              size: 14,
              color: selectedMember != null ? colors.primary : colors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              selectedMember != null
                  ? (selectedMember!.displayName.isNotEmpty
                      ? selectedMember!.displayName
                      : selectedMember!.initials)
                  : LocaleKeys.assignTo.tr,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selectedMember != null
                    ? colors.primary
                    : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
