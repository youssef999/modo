import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/features/daily/widgets/daily_date_strip.dart';
import 'package:life_daily_app/features/daily/widgets/daily_finance_card.dart';
import 'package:life_daily_app/features/daily/widgets/daily_habits_section.dart';
import 'package:life_daily_app/features/daily/widgets/daily_tasks_section.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';

class DailyHubPage extends StatelessWidget {
  const DailyHubPage({super.key, this.embed = false});

  final bool embed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return Scaffold(
      backgroundColor: colors.background,
      body: GetBuilder<GoalsController>(
        id: 'goals',
        builder: (goalsController) {
          final selectedDate = goalsController.selectedDailyDate;
          final habits = goalsController.habitsForDate(selectedDate);
          final taskGroups = goalsController.dailyTaskGroups(selectedDate);
          final progressData = goalsController.dailyProgress(selectedDate);

          return GetBuilder<FinanceController>(
            id: 'finance',
            builder: (financeController) {
              return RefreshIndicator(
                onRefresh: () async {
                  await goalsController.load();
                  await financeController.load();
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    embed ? AppSpacing.xxl * 3 : AppSpacing.xxl,
                  ),
                  children: [
                    // Date & Progress Strip
                    DailyDateStrip(
                      selectedDate: selectedDate,
                      onSelectDate: goalsController.setSelectedDailyDate,
                      completedCount: progressData.completed,
                      totalCount: progressData.total,
                      progress: progressData.progress,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Habits Section
                    DailyHabitsSection(
                      selectedDate: selectedDate,
                      habits: habits,
                      controller: goalsController,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Tasks Section
                    DailyTasksSection(
                      selectedDate: selectedDate,
                      groups: taskGroups,
                      controller: goalsController,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Finance Section
                    DailyFinanceCard(
                      selectedDate: selectedDate,
                      controller: financeController,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
