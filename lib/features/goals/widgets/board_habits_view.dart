import 'package:flutter/material.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/models/plan_period.dart';
import 'package:life_daily_app/features/goals/models/plan_snapshot.dart';
import 'package:life_daily_app/features/goals/widgets/plan_habit_tracker.dart';

/// Habit check grid for the board's period. Daily and General show the
/// week around the viewed day so there is a row of days to tick.
class BoardHabitsView extends StatelessWidget {
  const BoardHabitsView({super.key, required this.controller});

  final GoalsController controller;

  static Widget sliver(BuildContext context, GoalsController controller) {
    final scope = controller.boardScope;
    final period = scope.period;
    final gridPeriod = period == null || period == PlanPeriod.day
        ? PlanPeriod.week
        : period;
    final snapshot = PlanSnapshot.build(
      goals: controller.goals,
      period: gridPeriod,
      anchor: scope.anchor,
    );
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: PlanHabitTracker(
          snapshot: snapshot,
          controller: controller,
          addRepeat: period ?? PlanPeriod.day,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppLayout.wideMaxWidth),
        child: CustomScrollView(
          slivers: [
            sliver(context, controller),
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
