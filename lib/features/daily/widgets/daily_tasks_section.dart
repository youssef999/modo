import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/daily/widgets/daily_task_card.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/models/daily_task_groups.dart';
import 'package:life_daily_app/features/shell/widgets/quick_add_sheet.dart';

class DailyTasksSection extends StatelessWidget {
  const DailyTasksSection({
    super.key,
    required this.selectedDate,
    required this.groups,
    required this.controller,
  });

  final DateTime selectedDate;
  final DailyTaskGroups groups;
  final GoalsController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return Column(
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
                Icons.check_circle_outline_rounded,
                size: AppIconSize.sm,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              LocaleKeys.todayTasks.tr,
              style: AppTextStyles.h6(
                colors,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: AppSpacing.xs),
            _CountPill(count: groups.total, color: colors.textSecondary),
            const Spacer(),
            IconButton(
              onPressed: () => QuickAddSheet.show(context, date: selectedDate),
              icon: Icon(
                Icons.add_rounded,
                size: AppIconSize.md,
                color: colors.primary,
              ),
              tooltip: LocaleKeys.addTask.tr,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        if (groups.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: colors.border.withValues(alpha: 0.5)),
            ),
            child: Center(
              child: Text(
                LocaleKeys.noTasksToday.tr,
                style: AppTextStyles.body2(
                  colors,
                ).copyWith(color: colors.textSecondary),
              ),
            ),
          )
        else ...[
          _TaskGroup(
            label: LocaleKeys.overdue.tr,
            icon: Icons.warning_amber_rounded,
            color: colors.error,
            items: groups.overdue,
            controller: controller,
          ),
          _TaskGroup(
            label: LocaleKeys.scheduled.tr,
            icon: Icons.event_rounded,
            color: colors.primary,
            items: groups.scheduled,
            controller: controller,
          ),
          _TaskGroup(
            label: LocaleKeys.anytime.tr,
            icon: Icons.all_inclusive_rounded,
            color: colors.textSecondary,
            items: groups.anytime,
            controller: controller,
          ),
        ],
      ],
    );
  }
}

class _TaskGroup extends StatelessWidget {
  const _TaskGroup({
    required this.label,
    required this.icon,
    required this.color,
    required this.items,
    required this.controller,
  });

  final String label;
  final IconData icon;
  final Color color;
  final List<GoalTaskEntry> items;
  final GoalsController controller;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = context.appPalette;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                Icon(icon, size: AppIconSize.sm, color: color),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  label,
                  style: AppTextStyles.caption(
                    colors,
                  ).copyWith(color: color, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: AppSpacing.xs),
                _CountPill(count: items.length, color: color),
              ],
            ),
          ),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: DailyTaskCard(
                goal: item.goal,
                goalTitle: controller.goalTitle(item.goal),
                task: item.task,
                onToggle: () => controller.toggleTask(item.goal, item.task.id),
                onStatusChanged: (status) => controller.changeTaskStatus(
                  item.goal,
                  item.task.id,
                  status,
                ),
                onPriorityChanged: (priority) => controller.changeTaskPriority(
                  item.goal,
                  item.task.id,
                  priority,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs + AppSpacing.xs / 2,
        vertical: AppSpacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        '$count',
        style: AppTextStyles.caption(
          colors,
        ).copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
