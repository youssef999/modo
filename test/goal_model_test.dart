import 'package:flutter_test/flutter_test.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';

void main() {
  GoalModel habit({
    required DateTime start,
    required DateTime end,
    List<String> checkIns = const [],
  }) {
    return GoalModel(
      id: '1',
      ownerId: 'u1',
      title: 'Gym',
      details: '',
      kind: GoalKind.habit,
      startsAt: start,
      dueAt: end,
      category: 'healthy_routine',
      status: GoalStatus.active,
      checkIns: checkIns,
      createdAt: start,
      updatedAt: start,
    );
  }

  test('habit progress is days logged over the range, not only 0 or 100', () {
    final goal = habit(
      start: DateTime(2026, 8, 1),
      end: DateTime(2026, 8, 10),
      checkIns: const ['2026-08-01', '2026-08-02', '2026-08-03'],
    );
    expect(goal.plannedDays, 10);
    expect(goal.completedDays, 3);
    expect(goal.progressPercent, 30);
    expect(goal.isFullyComplete, isFalse);
  });

  test('habit can log yesterday inside the range and ignore future days', () {
    final today = DateTime(2026, 8, 20);
    final goal = habit(start: DateTime(2026, 8, 1), end: DateTime(2026, 8, 31));
    expect(goal.canLog(DateTime(2026, 8, 19), now: today), isTrue);
    expect(goal.canLog(DateTime(2026, 8, 21), now: today), isFalse);
    expect(goal.canLog(DateTime(2026, 7, 31), now: today), isFalse);
  });

  test('one-time goals stay binary', () {
    final now = DateTime(2026, 8, 20);
    final goal = GoalModel(
      id: '2',
      ownerId: 'u1',
      title: 'Pay rent',
      details: '',
      kind: GoalKind.once,
      startsAt: now,
      dueAt: now,
      category: 'work',
      status: GoalStatus.done,
      checkIns: const [],
      createdAt: now,
      updatedAt: now,
    );
    expect(goal.progressPercent, 100);
    expect(goal.isFullyComplete, isTrue);
  });
}
