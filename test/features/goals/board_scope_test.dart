import 'package:flutter_test/flutter_test.dart';
import 'package:life_daily_app/features/goals/models/board_scope.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';
import 'package:life_daily_app/features/goals/models/goal_task.dart';
import 'package:life_daily_app/features/goals/models/plan_period.dart';

GoalModel _goal({
  GoalKind kind = GoalKind.once,
  PlanPeriod? period,
  PlanPeriod repeat = PlanPeriod.day,
  DateTime? startsAt,
  required DateTime dueAt,
  GoalStatus status = GoalStatus.inProgress,
  bool isInbox = false,
}) {
  final created = DateTime(2026, 9, 1);
  return GoalModel(
    id: 'g',
    ownerId: 'u',
    title: 'Goal',
    details: '',
    kind: kind,
    startsAt: startsAt ?? dueAt,
    dueAt: dueAt,
    category: 'work',
    status: status,
    checkIns: const [],
    createdAt: created,
    updatedAt: created,
    period: period,
    repeat: repeat,
    isInbox: isInbox,
  );
}

void main() {
  // Wednesday; its week runs Sat 10 – Fri 16 Oct 2026.
  final today = DateTime(2026, 10, 14);
  final inbox = _goal(dueAt: today, isInbox: true);

  group('goals', () {
    test('a one-off goal shows in its period around its due date', () {
      final weekly = _goal(
        period: PlanPeriod.week,
        dueAt: DateTime(2026, 10, 16),
      );
      final week = BoardScope(period: PlanPeriod.week, anchor: today);
      expect(week.includesGoal(weekly, now: today), isTrue);
      expect(week.shift(1).includesGoal(weekly, now: today), isFalse);
      expect(
        BoardScope(period: PlanPeriod.day, anchor: today).includesGoal(weekly),
        isFalse,
      );
    });

    test('goals without a period are General', () {
      final general = _goal(dueAt: today);
      expect(BoardScope(anchor: today).includesGoal(general), isTrue);
      expect(
        BoardScope(
          period: PlanPeriod.month,
          anchor: today,
        ).includesGoal(general),
        isFalse,
      );
    });

    test('habits show in their repeat while active', () {
      final habit = _goal(
        kind: GoalKind.habit,
        repeat: PlanPeriod.week,
        startsAt: DateTime(2026, 10, 1),
        dueAt: DateTime(2026, 11, 30),
      );
      final week = BoardScope(period: PlanPeriod.week, anchor: today);
      expect(week.includesGoal(habit, now: today), isTrue);
      expect(week.shift(10).includesGoal(habit, now: today), isFalse);
      expect(BoardScope(anchor: today).includesGoal(habit), isFalse);
    });

    test('late daily goals stay on today until done', () {
      final late = _goal(period: PlanPeriod.day, dueAt: DateTime(2026, 10, 12));
      final todayScope = BoardScope(period: PlanPeriod.day, anchor: today);
      expect(todayScope.includesGoal(late, now: today), isTrue);
      expect(todayScope.shift(1).includesGoal(late, now: today), isFalse);
      expect(
        todayScope.includesGoal(
          _goal(
            period: PlanPeriod.day,
            dueAt: DateTime(2026, 10, 12),
            status: GoalStatus.done,
          ),
          now: today,
        ),
        isFalse,
      );
    });
  });

  group('tasks', () {
    test('dated tasks show on their day, undated inbox tasks in General', () {
      final dated = GoalTask(id: 'a', title: 'A', dueDate: today);
      const undated = GoalTask(id: 'b', title: 'B');
      final day = BoardScope(period: PlanPeriod.day, anchor: today);
      expect(day.includesTask(inbox, dated, now: today), isTrue);
      expect(day.includesTask(inbox, undated, now: today), isFalse);
      expect(BoardScope(anchor: today).includesTask(inbox, undated), isTrue);
      expect(BoardScope(anchor: today).includesTask(inbox, dated), isFalse);
    });

    test('undated tasks of a real goal stay inside the goal card', () {
      const undated = GoalTask(id: 'b', title: 'B');
      final goal = _goal(dueAt: today);
      expect(BoardScope(anchor: today).includesTask(goal, undated), isFalse);
    });

    test('week tasks show on the week, not on its days', () {
      final task = GoalTask(
        id: 'w',
        title: 'W',
        dueDate: DateTime(2026, 10, 10),
        period: PlanPeriod.week,
      );
      expect(
        BoardScope(
          period: PlanPeriod.week,
          anchor: today,
        ).includesTask(inbox, task, now: today),
        isTrue,
      );
      expect(
        BoardScope(
          period: PlanPeriod.day,
          anchor: DateTime(2026, 10, 10),
        ).includesTask(inbox, task, now: today),
        isFalse,
      );
    });

    test('overdue tasks join today only, and only while unfinished', () {
      final late = GoalTask(
        id: 'l',
        title: 'L',
        dueDate: DateTime(2026, 10, 11),
      );
      final todayScope = BoardScope(period: PlanPeriod.day, anchor: today);
      expect(BoardScope.isOverdue(late, now: today), isTrue);
      expect(todayScope.includesTask(inbox, late, now: today), isTrue);
      expect(
        todayScope.shift(1).includesTask(inbox, late, now: today),
        isFalse,
      );
      final done = late.copyWith(status: GoalTaskStatus.done);
      expect(todayScope.includesTask(inbox, done, now: today), isFalse);
    });
  });

  test('General ignores navigation', () {
    final general = BoardScope(anchor: today);
    expect(general.shift(3).anchor, today);
    expect(general.isCurrent(now: DateTime(2030)), isTrue);
  });
}
