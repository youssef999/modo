import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/daily/widgets/daily_task_card.dart';
import 'package:life_daily_app/features/daily/widgets/plan_section_header.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/models/plan_period.dart';
import 'package:life_daily_app/features/goals/models/plan_snapshot.dart';
import 'package:life_daily_app/features/shell/widgets/quick_add_sheet.dart';

/// Tasks planned for the whole viewed period ("Week goals", …).
class PlanTasksCard extends StatelessWidget {
  const PlanTasksCard({
    super.key,
    required this.snapshot,
    required this.controller,
  });

  final PlanSnapshot snapshot;
  final GoalsController controller;

  String get _title => switch (snapshot.period) {
    PlanPeriod.day || PlanPeriod.week => LocaleKeys.planWeekTasks.tr,
    PlanPeriod.month => LocaleKeys.planMonthTasks.tr,
    PlanPeriod.year => LocaleKeys.planYearTasks.tr,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final tasks = snapshot.tasks;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PlanSectionHeader(
              icon: Icons.flag_rounded,
              tone: colors.primary,
              title: _title,
              count: tasks.length,
              addTooltip: LocaleKeys.addTask.tr,
              onAdd: () => QuickAddSheet.show(
                context,
                date: snapshot.start,
                period: snapshot.period,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  LocaleKeys.planNoTasks.tr,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body2(
                    colors,
                  ).copyWith(color: colors.textSecondary),
                ),
              )
            else
              for (final item in tasks)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: DailyTaskCard(
                    goal: item.goal,
                    goalTitle: controller.goalTitle(item.goal),
                    task: item.task,
                    onToggle: () =>
                        controller.toggleTask(item.goal, item.task.id),
                    onStatusChanged: (status) => controller.changeTaskStatus(
                      item.goal,
                      item.task.id,
                      status,
                    ),
                    onPriorityChanged: (priority) => controller
                        .changeTaskPriority(item.goal, item.task.id, priority),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
