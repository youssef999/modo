import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/features/daily/controllers/plan_controller.dart';
import 'package:life_daily_app/features/daily/widgets/daily_date_strip.dart';
import 'package:life_daily_app/features/daily/widgets/daily_finance_card.dart';
import 'package:life_daily_app/features/daily/widgets/daily_habits_section.dart';
import 'package:life_daily_app/features/daily/widgets/daily_tasks_section.dart';
import 'package:life_daily_app/features/daily/widgets/plan_breakdown.dart';
import 'package:life_daily_app/features/daily/widgets/plan_habit_tracker.dart';
import 'package:life_daily_app/features/daily/widgets/plan_period_header.dart';
import 'package:life_daily_app/features/daily/widgets/plan_period_switch.dart';
import 'package:life_daily_app/features/daily/widgets/plan_tasks_card.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/models/plan_period.dart';

/// The Plan tab: Day / Week / Month / Year views of tasks and habits.
class DailyHubPage extends StatelessWidget {
  const DailyHubPage({super.key, this.embed = false});

  final bool embed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return Scaffold(
      backgroundColor: colors.background,
      body: GetBuilder<PlanController>(
        id: 'plan',
        builder: (plan) => GetBuilder<GoalsController>(
          id: 'goals',
          builder: (goals) => GetBuilder<FinanceController>(
            id: 'finance',
            builder: (finance) => LayoutBuilder(
              builder: (context, constraints) {
                final side =
                    (constraints.maxWidth - AppLayout.readableMaxWidth) / 2;
                return RefreshIndicator(
                  onRefresh: () async {
                    await goals.load();
                    await finance.load();
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      side > AppSpacing.md ? side : AppSpacing.md,
                      AppSpacing.sm,
                      side > AppSpacing.md ? side : AppSpacing.md,
                      embed ? AppSpacing.xxl * 3 : AppSpacing.xxl,
                    ),
                    children: [
                      PlanPeriodSwitch(
                        value: plan.period,
                        onChanged: plan.setPeriod,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (plan.period == PlanPeriod.day)
                        ..._dayView(goals, finance)
                      else
                        ..._periodView(plan, goals),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _dayView(GoalsController goals, FinanceController finance) {
    final date = goals.selectedDailyDate;
    final progress = goals.dailyProgress(date);
    return [
      DailyDateStrip(
        selectedDate: date,
        onSelectDate: goals.setSelectedDailyDate,
        completedCount: progress.completed,
        totalCount: progress.total,
        progress: progress.progress,
      ),
      const SizedBox(height: AppSpacing.md),
      DailyHabitsSection(
        selectedDate: date,
        habits: goals.habitsForDate(date),
        controller: goals,
      ),
      const SizedBox(height: AppSpacing.md),
      DailyTasksSection(
        selectedDate: date,
        groups: goals.dailyTaskGroups(date),
        controller: goals,
      ),
      const SizedBox(height: AppSpacing.md),
      DailyFinanceCard(selectedDate: date, controller: finance),
    ];
  }

  List<Widget> _periodView(PlanController plan, GoalsController goals) {
    final snapshot = plan.snapshot(goals.goals);
    return [
      PlanPeriodHeader(snapshot: snapshot, controller: plan),
      const SizedBox(height: AppSpacing.md),
      PlanHabitTracker(snapshot: snapshot, controller: goals),
      const SizedBox(height: AppSpacing.md),
      PlanTasksCard(snapshot: snapshot, controller: goals),
      const SizedBox(height: AppSpacing.md),
      PlanBreakdown(snapshot: snapshot, plan: plan, goals: goals),
    ];
  }
}
