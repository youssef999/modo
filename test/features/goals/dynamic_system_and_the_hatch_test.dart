import 'package:flutter_test/flutter_test.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';
import 'package:life_daily_app/features/goals/models/goal_task.dart';
import 'package:life_daily_app/features/goals/models/goal_tracker.dart';
import 'package:life_daily_app/features/finance/models/finance_commitment.dart';
import 'package:life_daily_app/features/finance/models/finance_entry.dart';
import 'package:life_daily_app/features/finance/models/finance_month_snapshot.dart';

void main() {
  group('The Hatch & Dynamic Systems Real-World Simulation Test', () {
    test(
      'Simulating "The Hatch" Startup Management Hub with Dynamic Tasks & KPIs',
      () {
        final now = DateTime.now();

        // 1. Initial State of "The Hatch"
        var theHatchGoal = GoalModel(
          id: 'the-hatch-001',
          ownerId: 'founder-uid',
          title: 'The Hatch — Startup Launch & Scaling',
          details:
              'Unified project framework for marketing, content, revenue, and MVP',
          kind: GoalKind.once,
          startsAt: now,
          dueAt: now.add(const Duration(days: 90)),
          category: 'work',
          status: GoalStatus.active,
          checkIns: const [],
          createdAt: now,
          updatedAt: now,
          tasks: const [
            GoalTask(
              id: 't1',
              title: 'Finalize Pitch Deck & Market Analysis',
              isCompleted: false,
              order: 0,
            ),
            GoalTask(
              id: 't2',
              title: 'Conduct 20 Customer Discovery Interviews',
              isCompleted: false,
              order: 1,
            ),
            GoalTask(
              id: 't3',
              title: 'Build & Deploy MVP on Web & Mobile',
              isCompleted: false,
              order: 2,
            ),
            GoalTask(
              id: 't4',
              title: 'Setup Stripe & Payment Integration',
              isCompleted: false,
              order: 3,
            ),
          ],
          trackers: const [
            GoalTracker(
              id: 'kpi_revenue',
              title: 'Monthly Recurring Revenue (MRR)',
              kind: GoalTrackerKind.numeric,
              current: 0,
              target: 10000,
              unit: '\$',
            ),
            GoalTracker(
              id: 'kpi_users',
              title: 'Early Beta Users',
              kind: GoalTrackerKind.numeric,
              current: 0,
              target: 100,
              unit: 'users',
            ),
            GoalTracker(
              id: 'kpi_phase',
              title: 'Startup Growth Phase',
              kind: GoalTrackerKind.milestone,
              milestones: [
                'Idea Validation',
                'MVP Build',
                'Alpha Testing',
                'Public Launch',
              ],
              currentMilestoneIndex: 0,
            ),
          ],
        );

        // Verify Initial State
        expect(theHatchGoal.tasks.length, 4);
        expect(theHatchGoal.completedTasksCount, 0);
        expect(theHatchGoal.taskCompletionRate, 0.0);
        expect(theHatchGoal.trackers.length, 3);
        expect(theHatchGoal.overallSuccessRate, 0.0);

        // 2. Action: Check off 2 Tasks
        final updatedTasks = theHatchGoal.tasks.map((task) {
          if (task.id == 't1' || task.id == 't2') {
            return task.copyWith(isCompleted: true);
          }
          return task;
        }).toList();

        theHatchGoal = theHatchGoal.copyWith(tasks: updatedTasks);

        expect(theHatchGoal.completedTasksCount, 2);
        expect(theHatchGoal.taskCompletionRate, 0.5); // 50% tasks complete

        // 3. Action: Update KPIs (Revenue to $3,500 / $10,000, Users to 45 / 100, Phase to Alpha Testing)
        final updatedTrackers = theHatchGoal.trackers.map((tracker) {
          if (tracker.id == 'kpi_revenue') {
            return tracker.copyWith(current: 3500); // 35%
          } else if (tracker.id == 'kpi_users') {
            return tracker.copyWith(current: 45); // 45%
          } else if (tracker.id == 'kpi_phase') {
            return tracker.copyWith(currentMilestoneIndex: 2); // 2/4 = 50%
          }
          return tracker;
        }).toList();

        theHatchGoal = theHatchGoal.copyWith(trackers: updatedTrackers);

        // Verify Trackers individually
        final revenueTracker = theHatchGoal.trackers.firstWhere(
          (t) => t.id == 'kpi_revenue',
        );
        expect(revenueTracker.progressPercent, 35);

        final userTracker = theHatchGoal.trackers.firstWhere(
          (t) => t.id == 'kpi_users',
        );
        expect(userTracker.progressPercent, 45);

        final phaseTracker = theHatchGoal.trackers.firstWhere(
          (t) => t.id == 'kpi_phase',
        );
        expect(phaseTracker.progressPercent, 50);

        // Verify Overall Blended Success Score
        // Tracker avg: (0.35 + 0.45 + 0.50) / 3 = 0.433
        // Tasks: 0.50
        // Base: 0.0
        // Blended = (0 + 0.5 + 0.433) / 2 = ~0.467 (47%)
        expect(theHatchGoal.overallSuccessPercent, greaterThanOrEqualTo(45));
        expect(theHatchGoal.overallSuccessPercent, lessThanOrEqualTo(50));

        // 4. Verify JSON Serialization & Data Integrity for Cloud Sync
        final map = theHatchGoal.toMap();
        final revived = GoalModel.fromMap(theHatchGoal.id, map);
        expect(revived.title, theHatchGoal.title);
        expect(revived.tasks.length, 4);
        expect(revived.tasks[0].isCompleted, true);
        expect(revived.tasks[1].isCompleted, true);
        expect(revived.tasks[2].isCompleted, false);
        expect(revived.trackers.length, 3);
        expect(revived.trackers[0].current, 3500);
        expect(
          revived.overallSuccessPercent,
          theHatchGoal.overallSuccessPercent,
        );
      },
    );

    test('Simulating Fitness & Nutrition Resistance Training System', () {
      final now = DateTime.now();

      final fitnessGoal = GoalModel(
        id: 'fitness-tracker-001',
        ownerId: 'athlete-uid',
        title: 'Hypertrophy & Strength 90-Day System',
        details: 'Daily diet tracking, progressive overload, and consistency',
        kind: GoalKind.habit,
        startsAt: now.subtract(const Duration(days: 10)),
        dueAt: now.add(const Duration(days: 80)),
        category: 'healthy_routine',
        status: GoalStatus.active,
        checkIns: [
          GoalModel.dateKey(now.subtract(const Duration(days: 1))),
          GoalModel.dateKey(now),
        ],
        createdAt: now,
        updatedAt: now,
        tasks: const [
          GoalTask(
            id: 'ft1',
            title: 'Daily Warm-up & Mobility',
            isCompleted: true,
          ),
          GoalTask(
            id: 'ft2',
            title: 'Resistance Workout Session (Push/Pull/Legs)',
            isCompleted: true,
          ),
          GoalTask(
            id: 'ft3',
            title: 'Hit Daily Protein Target (180g)',
            isCompleted: false,
          ),
          GoalTask(
            id: 'ft4',
            title: 'Hydration 3 Liters Clean Water',
            isCompleted: true,
          ),
          GoalTask(
            id: 'ft5',
            title: '8 Hours Quality Sleep',
            isCompleted: false,
          ),
        ],
        trackers: const [
          GoalTracker(
            id: 'bench_press',
            title: 'Bench Press Target',
            kind: GoalTrackerKind.numeric,
            current: 85,
            target: 100,
            unit: 'kg',
          ),
          GoalTracker(
            id: 'bodyweight',
            title: 'Target Bodyweight',
            kind: GoalTrackerKind.numeric,
            current: 78,
            target: 82,
            unit: 'kg',
          ),
        ],
      );

      expect(fitnessGoal.isHabit, true);
      expect(fitnessGoal.completedTasksCount, 3);
      expect(fitnessGoal.taskCompletionRate, 0.6); // 3/5 = 60%
      expect(fitnessGoal.trackers[0].progressPercent, 85); // 85kg / 100kg = 85%
      expect(fitnessGoal.overallSuccessPercent, greaterThan(0));
    });

    test('Simulating Finance Commitments & Real Safe Liquidity', () {
      final now = DateTime.now();
      final month = DateTime(now.year, now.month);

      final commitments = [
        FinanceCommitment(
          id: 'c1',
          ownerId: 'user-1',
          title: 'Cloud Servers & Hosting',
          amount: 150.0,
          dueDay: 5,
          isPaid: true,
          createdAt: now,
          updatedAt: now,
        ),
        FinanceCommitment(
          id: 'c2',
          ownerId: 'user-1',
          title: 'Office Space & Coworking',
          amount: 600.0,
          dueDay: 20,
          isPaid: false, // Unpaid liability
          createdAt: now,
          updatedAt: now,
        ),
        FinanceCommitment(
          id: 'c3',
          ownerId: 'user-1',
          title: 'SaaS Tool Subscriptions',
          amount: 250.0,
          dueDay: 25,
          isPaid: false, // Unpaid liability
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final entries = [
        FinanceEntry(
          id: 'e1',
          ownerId: 'user-1',
          kind: FinanceKind.salary,
          title: 'Client Retainer Income',
          amount: 4000.0,
          categoryId: 'cat_income',
          occurredAt: now,
          note: '',
          createdAt: now,
          updatedAt: now,
        ),
        FinanceEntry(
          id: 'e2',
          ownerId: 'user-1',
          kind: FinanceKind.expense,
          title: 'Equipment & Supplies',
          amount: 500.0,
          categoryId: 'cat_spend',
          occurredAt: now,
          note: '',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final snapshot = FinanceMonthSnapshot.from(
        entries: entries,
        categories: const [],
        month: month,
        commitments: commitments,
      );

      // Income = 4000, Spend = 500.
      // Total Commitments = 150 + 600 + 250 = 1000.
      // Unpaid Commitments = 600 + 250 = 850.
      // Paid Commitments = 150.
      expect(snapshot.income, 4000.0);
      expect(snapshot.spend, 500.0);
      expect(snapshot.commitmentsTotal, 1000.0);
      expect(snapshot.unpaidCommitments, 850.0);
      expect(snapshot.paidCommitments, 150.0);

      // Safe Liquidity = (Income 4000) - (Spend 500) - (Unpaid 850) = 2650.0
      expect(snapshot.safeLiquidity, 2650.0);
    });
  });
}
