import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_palette.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';
import 'package:life_daily_app/features/goals/models/goal_tracker.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';

class DynamicTrackerWidget extends StatelessWidget {
  const DynamicTrackerWidget({super.key, required this.goal});

  final GoalModel goal;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final controller = Get.find<GoalsController>();
    final currentGoal = controller.goalById(goal.id) ?? goal;
    final trackers = currentGoal.trackers;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: colors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.speed_rounded,
                  size: AppIconSize.md,
                  color: colors.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  LocaleKeys.trackers.tr,
                  style: AppTextStyles.h6(colors),
                ),
              ),
              IconButton(
                onPressed: () => _showAddTrackerDialog(context, currentGoal),
                icon: Icon(
                  Icons.add_rounded,
                  color: colors.primary,
                  size: AppIconSize.md,
                ),
                tooltip: LocaleKeys.addTracker.tr,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (trackers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Center(
                child: Text(
                  LocaleKeys.trackers.tr,
                  style: AppTextStyles.caption(colors),
                ),
              ),
            )
          else
            Column(
              children: [
                for (final tracker in trackers)
                  _TrackerCard(goal: currentGoal, tracker: tracker),
              ],
            ),
        ],
      ),
    );
  }

  void _showAddTrackerDialog(BuildContext context, GoalModel goal) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _AddTrackerDialog(goal: goal),
    );
  }
}

class _TrackerCard extends StatelessWidget {
  const _TrackerCard({required this.goal, required this.tracker});

  final GoalModel goal;
  final GoalTracker tracker;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final controller = Get.find<GoalsController>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: colors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      tracker.title,
                      style: AppTextStyles.body1(
                        colors,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '${tracker.progressPercent}%',
                    style: AppTextStyles.caption(colors).copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: AppIconSize.sm,
                      color: colors.textSecondary.withValues(alpha: 0.6),
                    ),
                    onPressed: () => controller.deleteTracker(goal, tracker.id),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: LinearProgressIndicator(
                  value: tracker.progress,
                  minHeight: 6,
                  backgroundColor: colors.border,
                  color: tracker.isCompleted ? colors.success : colors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              switch (tracker.kind) {
                GoalTrackerKind.numeric => _buildNumericControls(
                  context,
                  colors,
                  controller,
                ),
                GoalTrackerKind.milestone => _buildMilestoneControls(
                  context,
                  colors,
                  controller,
                ),
                GoalTrackerKind.streak => _buildStreakControls(
                  context,
                  colors,
                  controller,
                ),
              },
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumericControls(
    BuildContext context,
    AppPalette colors,
    GoalsController controller,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${tracker.current.round()} / ${tracker.target.round()} ${tracker.unit}',
          style: AppTextStyles.caption(colors),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
              onPressed: tracker.current > 0
                  ? () => controller.updateTrackerValue(
                      goal,
                      tracker.id,
                      (tracker.current - 1).clamp(0, tracker.target),
                    )
                  : null,
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.add_circle_outline_rounded,
                size: 20,
                color: colors.primary,
              ),
              onPressed: () => controller.updateTrackerValue(
                goal,
                tracker.id,
                tracker.current + 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMilestoneControls(
    BuildContext context,
    AppPalette colors,
    GoalsController controller,
  ) {
    final milestones = tracker.milestones;
    if (milestones.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < milestones.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: InkWell(
              onTap: () {
                final nextIdx = i < tracker.currentMilestoneIndex ? i : i + 1;
                controller.updateTrackerValue(
                  goal,
                  tracker.id,
                  nextIdx.toDouble(),
                  milestoneIndex: nextIdx,
                );
              },
              child: Row(
                children: [
                  Icon(
                    i < tracker.currentMilestoneIndex
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    size: 16,
                    color: i < tracker.currentMilestoneIndex
                        ? colors.success
                        : colors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      milestones[i],
                      style: AppTextStyles.caption(colors).copyWith(
                        decoration: i < tracker.currentMilestoneIndex
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStreakControls(
    BuildContext context,
    AppPalette colors,
    GoalsController controller,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              color: colors.warning,
              size: AppIconSize.md,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '${tracker.current.round()} / ${tracker.target.round()} ${tracker.unit}',
              style: AppTextStyles.body2(
                colors,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        AppButton(
          label: '+1',
          variant: AppButtonVariant.secondary,
          onPressed: () => controller.updateTrackerValue(
            goal,
            tracker.id,
            tracker.current + 1,
          ),
        ),
      ],
    );
  }
}

class _AddTrackerDialog extends StatefulWidget {
  const _AddTrackerDialog({required this.goal});

  final GoalModel goal;

  @override
  State<_AddTrackerDialog> createState() => _AddTrackerDialogState();
}

class _AddTrackerDialogState extends State<_AddTrackerDialog> {
  final _titleController = TextEditingController();
  final _targetController = TextEditingController(text: '10');
  final _unitController = TextEditingController();
  final _milestonesController = TextEditingController();
  GoalTrackerKind _kind = GoalTrackerKind.numeric;

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    _milestonesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return Dialog(
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(LocaleKeys.addTracker.tr, style: AppTextStyles.h6(colors)),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: LocaleKeys.noteTitle.tr,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<GoalTrackerKind>(
                  initialValue: _kind,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: GoalTrackerKind.numeric,
                      child: Text(LocaleKeys.trackerKindNumeric.tr),
                    ),
                    DropdownMenuItem(
                      value: GoalTrackerKind.milestone,
                      child: Text(LocaleKeys.trackerKindMilestone.tr),
                    ),
                    DropdownMenuItem(
                      value: GoalTrackerKind.streak,
                      child: Text(LocaleKeys.trackerKindStreak.tr),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _kind = val);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                if (_kind != GoalTrackerKind.milestone) ...[
                  TextField(
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: LocaleKeys.trackerTarget.tr,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _unitController,
                    decoration: InputDecoration(
                      labelText: LocaleKeys.trackerUnit.tr,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                  ),
                ] else ...[
                  TextField(
                    controller: _milestonesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Milestones (comma-separated)',
                      hintText: 'Phase 1, Phase 2, Launch',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                AppButton(label: LocaleKeys.save.tr, onPressed: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final target = double.tryParse(_targetController.text) ?? 10;
    final milestones = _milestonesController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final tracker = GoalTracker(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      kind: _kind,
      current: 0,
      target: _kind == GoalTrackerKind.milestone
          ? milestones.length.toDouble()
          : target,
      unit: _unitController.text.trim(),
      milestones: milestones,
    );

    Get.find<GoalsController>().addTracker(widget.goal, tracker);
    Navigator.of(context).pop();
  }
}
