import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/models/app_priority.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_palette.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';
import 'package:life_daily_app/features/goals/models/goal_task.dart';
import 'package:life_daily_app/features/goals/models/plan_period.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';
import 'package:life_daily_app/shared/widgets/inputs/app_text_field.dart';

import 'quick_add_period_chips.dart';
import 'quick_add_priority_chips.dart';
import 'quick_add_section_chips.dart';
import 'quick_add_when_chips.dart';

class QuickAddTaskForm extends StatefulWidget {
  const QuickAddTaskForm({
    super.key,
    required this.onDone,
    this.date,
    this.status,
    this.goalId,
    this.categoryId,
    this.period,
    this.repeat = false,
    this.undated = false,
  });

  final VoidCallback onDone;
  final DateTime? date;
  final GoalTaskStatus? status;
  final String? goalId;
  final String? categoryId;
  final PlanPeriod? period;
  final bool repeat;

  /// Starts with "Anytime" (no date), e.g. from the General board.
  final bool undated;

  @override
  State<QuickAddTaskForm> createState() => _QuickAddTaskFormState();
}

class _QuickAddTaskFormState extends State<QuickAddTaskForm> {
  final _titleController = TextEditingController();
  late DateTime? _dueDate;
  late PlanPeriod _period;
  late bool _repeat;
  String? _goalId;
  String? _categoryId;
  AppPriority _priority = AppPriority.medium;
  bool _saving = false;

  GoalsController get _goals => Get.find<GoalsController>();

  bool get _isSpan => _period != PlanPeriod.day;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _period = widget.period ?? PlanPeriod.day;
    _repeat = widget.repeat;
    _dueDate =
        widget.date ??
        (widget.status != null || widget.undated
            ? null
            : DateTime(now.year, now.month, now.day));
    if (_isSpan) _dueDate = _period.startOf(_dueDate ?? now);
    final initialGoal = widget.goalId == null
        ? null
        : _goals.goalById(widget.goalId!);
    _goalId = initialGoal == null || initialGoal.isInbox
        ? null
        : initialGoal.id;
    _categoryId = widget.categoryId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _setPeriod(PlanPeriod next) {
    if (next == _period) return;
    final now = DateTime.now();
    setState(() {
      _period = next;
      _dueDate = next == PlanPeriod.day
          ? DateTime(now.year, now.month, now.day)
          : next.startOf(_dueDate ?? now);
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _saving) return;
    setState(() => _saving = true);
    if (_repeat) {
      await _goals.quickAddHabit(
        title: title,
        repeat: _period,
        categoryId: _categoryId,
        priority: _priority,
      );
    } else {
      await _goals.quickAddTask(
        goalId: _goalId,
        title: title,
        status: widget.status ?? GoalTaskStatus.todo,
        priority: _priority,
        dueDate: _dueDate,
        categoryId: _categoryId,
        period: _period,
      );
    }
    if (mounted) widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final goals = _goals.realGoals.where((g) => !g.isArchived).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: _titleController,
          label: LocaleKeys.quickAddTaskHint.tr,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: AppSpacing.md),
        _Caption(LocaleKeys.planFor.tr),
        const SizedBox(height: AppSpacing.xs),
        QuickAddPeriodChips(
          period: _period,
          repeat: _repeat,
          onPeriodChanged: _setPeriod,
          onRepeatChanged: (value) => setState(() => _repeat = value),
        ),
        if (!_repeat) ...[
          const SizedBox(height: AppSpacing.sm),
          if (_isSpan)
            QuickAddSpanChips(
              period: _period,
              value: _dueDate ?? _period.startOf(DateTime.now()),
              onChanged: (value) => setState(() => _dueDate = value),
            )
          else
            QuickAddWhenChips(
              value: _dueDate,
              onChanged: (value) => setState(() => _dueDate = value),
            ),
          const SizedBox(height: AppSpacing.md),
          _goalPicker(colors, goals),
        ],
        const SizedBox(height: AppSpacing.md),
        _Caption(LocaleKeys.taskSection.tr),
        const SizedBox(height: AppSpacing.xs),
        QuickAddSectionChips(
          controller: _goals,
          value: _categoryId,
          onChanged: (value) => setState(() => _categoryId = value),
        ),
        const SizedBox(height: AppSpacing.md),
        QuickAddPriorityChips(
          value: _priority,
          onChanged: (value) => setState(() => _priority = value),
        ),
        const SizedBox(height: AppSpacing.lg),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _titleController,
          builder: (context, value, _) => AppButton(
            label: LocaleKeys.save.tr,
            onPressed: value.text.trim().isEmpty || _saving ? null : _save,
          ),
        ),
      ],
    );
  }

  Widget _goalPicker(AppPalette colors, List<GoalModel> goals) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: _goalId,
            isExpanded: true,
            dropdownColor: colors.card,
            icon: Icon(
              Icons.expand_more_rounded,
              size: AppIconSize.md,
              color: colors.textSecondary,
            ),
            style: AppTextStyles.body2(colors),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: _GoalOption(
                  icon: Icons.inbox_rounded,
                  label: LocaleKeys.generalTasks.tr,
                ),
              ),
              for (final goal in goals)
                DropdownMenuItem<String?>(
                  value: goal.id,
                  child: _GoalOption(
                    icon: Icons.flag_rounded,
                    label: goal.title,
                  ),
                ),
            ],
            onChanged: (value) => setState(() => _goalId = value),
          ),
        ),
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Text(
      text,
      style: AppTextStyles.caption(
        colors,
      ).copyWith(color: colors.textSecondary, fontWeight: FontWeight.w600),
    );
  }
}

class _GoalOption extends StatelessWidget {
  const _GoalOption({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Row(
      children: [
        Icon(icon, size: AppIconSize.sm, color: colors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body2(colors),
          ),
        ),
      ],
    );
  }
}
