import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/models/app_priority.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_gradients.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';
import 'package:life_daily_app/features/goals/widgets/app_priority_picker.dart';
import 'package:life_daily_app/features/goals/widgets/app_status_picker.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';
import 'package:life_daily_app/shared/widgets/inputs/app_text_field.dart';
import 'package:life_daily_app/shared/widgets/layout/app_scaffold.dart';

class GoalEditorPage extends StatefulWidget {
  const GoalEditorPage({super.key, this.goal});

  final GoalModel? goal;

  @override
  State<GoalEditorPage> createState() => _GoalEditorPageState();
}

class _GoalEditorPageState extends State<GoalEditorPage> {
  late final TextEditingController _title;
  late final TextEditingController _details;
  late GoalKind _kind;
  late DateTime _startsAt;
  late DateTime _dueAt;
  late String _categoryId;
  late bool _pickingCategory;
  late GoalStatus _status;
  late AppPriority _priority;

  @override
  void initState() {
    super.initState();
    final goal = widget.goal;
    final today = GoalModel.dateOnly(DateTime.now());
    final controller = Get.find<GoalsController>();
    _title = TextEditingController(text: goal?.title ?? '');
    _details = TextEditingController(text: goal?.details ?? '');
    _kind = goal?.kind ?? GoalKind.once;
    _startsAt = goal?.startsAt ?? today;
    _dueAt = goal?.dueAt ?? today;
    _categoryId = goal?.category ?? controller.selectedCategoryId ?? '';
    _pickingCategory = widget.goal == null;
    _status = goal?.status ?? GoalStatus.notStarted;
    _priority = goal?.priority ?? AppPriority.medium;
  }

  @override
  void dispose() {
    _title.dispose();
    _details.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.goal != null;
    return GetBuilder<GoalsController>(
      id: 'goals',
      builder: (controller) {
        if (_pickingCategory) {
          return _CategoryStep(
            selectedId: _categoryId,
            onSelect: (id) => setState(() {
              _categoryId = id;
              _pickingCategory = false;
            }),
            onBack: () => setState(() => _pickingCategory = false),
          );
        }
        return AppScaffold(
          title: isEdit ? LocaleKeys.editGoal.tr : LocaleKeys.addGoal.tr,
          bottomBar: AppButton(label: LocaleKeys.save.tr, onPressed: _save),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                _SelectedCategory(
                  categoryId: _categoryId,
                  onChange: () => setState(() => _pickingCategory = true),
                ),
                const SizedBox(height: AppSpacing.md),
                _StatusTile(
                  status: _status,
                  onChanged: (s) => setState(() => _status = s),
                ),
                const SizedBox(height: AppSpacing.md),
                _PriorityTile(
                  priority: _priority,
                  onChanged: (p) => setState(() => _priority = p),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _title,
                  label: LocaleKeys.goalName.tr,
                  autofocus: true,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _details,
                  label: LocaleKeys.goalDetails.tr,
                  maxLines: 4,
                ),
                const SizedBox(height: AppSpacing.md),
                _KindToggle(value: _kind, onChanged: _setKind),
                const SizedBox(height: AppSpacing.md),
                if (_kind == GoalKind.habit) ...[
                  _DateTile(
                    label: LocaleKeys.goalStartDate.tr,
                    value: _startsAt,
                    onTap: () => _pickDate(isStart: true),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _DateTile(
                    label: LocaleKeys.goalEndDate.tr,
                    value: _dueAt,
                    onTap: () => _pickDate(isStart: false),
                  ),
                ] else
                  _DateTile(
                    label: LocaleKeys.goalDate.tr,
                    value: _dueAt,
                    onTap: () => _pickDate(isStart: false),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  },
);
  }

  void _setKind(GoalKind kind) {
    final today = GoalModel.dateOnly(DateTime.now());
    setState(() {
      _kind = kind;
      if (kind == GoalKind.habit) {
        _startsAt = today;
        if (!_dueAt.isAfter(_startsAt)) {
          _dueAt = _startsAt.add(const Duration(days: 29));
        }
      } else {
        _startsAt = _dueAt;
      }
    });
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startsAt : _dueAt;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    final value = GoalModel.dateOnly(picked);
    setState(() {
      if (isStart) {
        _startsAt = value;
        if (_dueAt.isBefore(_startsAt)) _dueAt = _startsAt;
      } else {
        _dueAt = value;
        if (_kind == GoalKind.habit && _startsAt.isAfter(_dueAt)) {
          _startsAt = _dueAt;
        }
        if (_kind == GoalKind.once) _startsAt = _dueAt;
      }
    });
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty || _categoryId.isEmpty) return;
    final controller = Get.find<GoalsController>();
    if (widget.goal == null) {
      await controller.addGoal(
        title: title,
        details: _details.text,
        kind: _kind,
        startsAt: _kind == GoalKind.habit ? _startsAt : _dueAt,
        dueAt: _dueAt,
        category: _categoryId,
        status: _status,
        priority: _priority,
      );
    } else {
      final checkIns = _kind == GoalKind.habit
          ? widget.goal!.checkIns
          : const <String>[];
      await controller.editGoal(
        widget.goal!.copyWith(
          title: title,
          details: _details.text.trim(),
          kind: _kind,
          startsAt: _kind == GoalKind.habit ? _startsAt : _dueAt,
          dueAt: _dueAt,
          category: _categoryId,
          status: _status,
          priority: _priority,
          checkIns: checkIns,
          updatedAt: DateTime.now(),
        ),
      );
    }
    Get.back();
  }
}

class _CategoryStep extends StatelessWidget {
  const _CategoryStep({
    required this.selectedId,
    required this.onSelect,
    required this.onBack,
  });

  final String selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return AppScaffold(
      title: LocaleKeys.goalCategory.tr,
      onBack: onBack,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: GetBuilder<GoalsController>(
            id: 'goals',
            builder: (controller) {
              return Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      itemCount: controller.categories.length + 1,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 120,
                        mainAxisSpacing: AppSpacing.md,
                        crossAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.82,
                      ),
                  itemBuilder: (context, index) {
                    if (index == controller.categories.length) {
                      return GestureDetector(
                        onTap: () async {
                          final id = await AppNavigator.toGoalCategory();
                          if (id == null || id.isEmpty) return;
                          onSelect(id);
                        },
                        child: Column(
                          children: [
                            Container(
                              width: AppSpacing.xxl + AppSpacing.sm,
                              height: AppSpacing.xxl + AppSpacing.sm,
                              decoration: BoxDecoration(
                                color: colors.surface,
                                shape: BoxShape.circle,
                                border: Border.all(color: colors.primary),
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                color: colors.primary,
                                size: AppIconSize.lg,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              LocaleKeys.addCategory.tr,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption(colors),
                            ),
                          ],
                        ),
                      );
                    }
                    final category = controller.categories[index];
                    final selected = category.id == selectedId;
                    final tint = category.color(colors);
                    return GestureDetector(
                      onTap: () => onSelect(category.id),
                      child: Column(
                        children: [
                          Container(
                            width: AppSpacing.xxl + AppSpacing.sm,
                            height: AppSpacing.xxl + AppSpacing.sm,
                            decoration: BoxDecoration(
                              color: colors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected
                                    ? colors.primary
                                    : colors.border,
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Icon(
                              category.icon,
                              color: tint,
                              size: AppIconSize.lg,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            controller.categoryLabel(category),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption(colors),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            );
          },
        ),
      ),
    ),
  );
}
}

class _SelectedCategory extends StatelessWidget {
  const _SelectedCategory({required this.categoryId, required this.onChange});

  final String categoryId;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final controller = Get.find<GoalsController>();
    final category = controller.categoryById(categoryId);
    if (category == null) {
      return AppButton(
        label: LocaleKeys.goalCategory.tr,
        onPressed: onChange,
        variant: AppButtonVariant.secondary,
      );
    }
    return GestureDetector(
      onTap: onChange,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Icon(category.icon, color: category.color(colors)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                controller.categoryLabel(category),
                style: AppTextStyles.body1(colors),
              ),
            ),
            Icon(
              Icons.swap_horiz_rounded,
              color: colors.textSecondary,
              size: AppIconSize.md,
            ),
          ],
        ),
      ),
    );
  }
}

class _KindToggle extends StatelessWidget {
  const _KindToggle({required this.value, required this.onChanged});

  final GoalKind value;
  final ValueChanged<GoalKind> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KindChip(
            label: LocaleKeys.goalKindOnce.tr,
            selected: value == GoalKind.once,
            onTap: () => onChanged(GoalKind.once),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _KindChip(
            label: LocaleKeys.goalKindHabit.tr,
            selected: value == GoalKind.habit,
            onTap: () => onChanged(GoalKind.habit),
          ),
        ),
      ],
    );
  }
}

class _KindChip extends StatelessWidget {
  const _KindChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: selected ? null : colors.surface,
          gradient: selected ? AppGradients.primary(colors) : null,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: selected ? colors.primary : colors.border),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption(colors).copyWith(
            color: selected ? colors.onPrimary : colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption(colors)),
        const SizedBox(height: AppSpacing.xs),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: colors.border),
            ),
            child: Text(
              MaterialLocalizations.of(context).formatMediumDate(value),
              style: AppTextStyles.body1(colors),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({required this.status, required this.onChanged});

  final GoalStatus status;
  final ValueChanged<GoalStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LocaleKeys.selectStatus.tr, style: AppTextStyles.caption(colors)),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              GoalStatusBadge(
                status: status,
                onChanged: onChanged,
              ),
              const Spacer(),
              Text(
                LocaleKeys.changeStatus.tr,
                style: AppTextStyles.caption(colors).copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PriorityTile extends StatelessWidget {
  const _PriorityTile({required this.priority, required this.onChanged});

  final AppPriority priority;
  final ValueChanged<AppPriority> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LocaleKeys.selectPriority.tr, style: AppTextStyles.caption(colors)),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              GoalPriorityBadge(
                priority: priority,
                onChanged: onChanged,
              ),
              const Spacer(),
              Text(
                LocaleKeys.changePriority.tr,
                style: AppTextStyles.caption(colors).copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

