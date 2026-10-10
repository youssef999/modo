import 'package:flutter_test/flutter_test.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';
import 'package:life_daily_app/features/goals/models/goal_task.dart';
import 'package:life_daily_app/features/goals/models/plan_period.dart';
import 'package:life_daily_app/features/goals/models/plan_snapshot.dart';

GoalModel _goal(
  String id, {
  GoalKind kind = GoalKind.once,
  PlanPeriod repeat = PlanPeriod.day,
  DateTime? startsAt,
  DateTime? dueAt,
  List<String> checkIns = const [],
  List<GoalTask> tasks = const [],
}) {
  final created = DateTime(2026, 9, 1);
  return GoalModel(
    id: id,
    ownerId: 'user_1',
    title: id,
    details: '',
    kind: kind,
    startsAt: startsAt ?? created,
    dueAt: dueAt ?? DateTime(2026, 12, 31),
    category: 'work',
    status: GoalStatus.inProgress,
    checkIns: checkIns,
    createdAt: created,
    updatedAt: created,
    tasks: tasks,
    repeat: repeat,
  );
}

void main() {
  // 10 Oct 2026 is a Saturday, the first day of the week.
  final saturday = DateTime(2026, 10, 10);
  final wednesday = DateTime(2026, 10, 14);

  group('PlanPeriod', () {
    test('weeks run Saturday to Friday', () {
      expect(PlanPeriod.week.startOf(wednesday), saturday);
      expect(PlanPeriod.week.startOf(saturday), saturday);
      expect(PlanPeriod.week.startOf(DateTime(2026, 10, 16)), saturday);
      expect(PlanPeriod.week.endOf(wednesday), DateTime(2026, 10, 16));
      expect(
        PlanPeriod.week.startOf(DateTime(2026, 10, 17)),
        DateTime(2026, 10, 17),
      );
    });

    test('months and years start on their first day', () {
      expect(PlanPeriod.month.startOf(wednesday), DateTime(2026, 10));
      expect(PlanPeriod.month.endOf(wednesday), DateTime(2026, 10, 31));
      expect(
        PlanPeriod.month.shift(DateTime(2026, 1, 31), 1),
        DateTime(2026, 2),
      );
      expect(PlanPeriod.year.startOf(wednesday), DateTime(2026));
      expect(PlanPeriod.year.endOf(wednesday), DateTime(2026, 12, 31));
    });

    test('breaks down into the next smaller period', () {
      expect(PlanPeriod.week.breakdown, PlanPeriod.day);
      expect(PlanPeriod.month.breakdown, PlanPeriod.week);
      expect(PlanPeriod.year.breakdown, PlanPeriod.month);
      expect(PlanPeriod.day.breakdown, isNull);
    });
  });

  group('Weekly habit', () {
    final habit = _goal(
      'read',
      kind: GoalKind.habit,
      repeat: PlanPeriod.week,
      startsAt: DateTime(2026, 10, 3),
    );

    test('any day of the week shares one check-in key', () {
      expect(habit.checkKey(wednesday), '2026-10-10');
      expect(habit.checkKey(DateTime(2026, 10, 16)), '2026-10-10');
    });

    test('future weeks cannot be checked yet', () {
      expect(habit.canLog(wednesday, now: wednesday), isTrue);
      expect(habit.canLog(DateTime(2026, 10, 17), now: wednesday), isFalse);
    });

    test('repeat survives toMap/fromMap', () {
      final restored = GoalModel.fromMap('read', habit.toMap());
      expect(restored.repeat, PlanPeriod.week);
      expect(GoalModel.fromMap('x', _goal('x').toMap()).repeat, PlanPeriod.day);
    });
  });

  group('PlanSnapshot', () {
    final goals = [
      _goal(
        'tasks',
        tasks: [
          GoalTask(
            id: 'week_done',
            title: 'Week goal',
            dueDate: saturday,
            period: PlanPeriod.week,
            status: GoalTaskStatus.done,
          ),
          GoalTask(id: 'mon', title: 'Monday', dueDate: DateTime(2026, 10, 12)),
          GoalTask(id: 'next', title: 'Later', dueDate: DateTime(2026, 10, 20)),
          GoalTask(
            id: 'month',
            title: 'Month goal',
            dueDate: DateTime(2026, 10),
            period: PlanPeriod.month,
          ),
        ],
      ),
      _goal(
        'weekly',
        kind: GoalKind.habit,
        repeat: PlanPeriod.week,
        startsAt: DateTime(2026, 10, 3),
        checkIns: const ['2026-10-10'],
      ),
      _goal(
        'daily',
        kind: GoalKind.habit,
        startsAt: saturday,
        dueAt: DateTime(2026, 10, 12),
        checkIns: const ['2026-10-11'],
      ),
    ];

    test('week counts its tasks, its days and its habits', () {
      final snapshot = PlanSnapshot.build(
        goals: goals,
        period: PlanPeriod.week,
        anchor: wednesday,
        now: wednesday,
      );
      expect(snapshot.start, saturday);
      expect(snapshot.tasks.map((e) => e.task.id), ['week_done']);
      // Tasks: week_done ✓, mon. Daily habit: 3 days, 1 ✓. Weekly: 1 ✓.
      expect(snapshot.total, 6);
      expect(snapshot.done, 3);
      expect(snapshot.percent, 50);
      expect(snapshot.habitGroups.map((g) => g.repeat), [
        PlanPeriod.day,
        PlanPeriod.week,
      ]);

      expect(snapshot.children, hasLength(7));
      final monday = snapshot.children[2];
      expect(monday.start, DateTime(2026, 10, 12));
      expect(monday.tasks.map((e) => e.task.id), ['mon']);
      expect(monday.total, 2);
      expect(monday.done, 0);
    });

    test('month includes smaller periods but not bigger ones', () {
      final snapshot = PlanSnapshot.build(
        goals: goals,
        period: PlanPeriod.month,
        anchor: wednesday,
        now: wednesday,
      );
      expect(snapshot.tasks.map((e) => e.task.id), ['month']);
      final weekly = snapshot.habitGroups.firstWhere(
        (g) => g.repeat == PlanPeriod.week,
      );
      expect(weekly.rows.single.total, 5);
      // Tasks: 4, 1 ✓. Daily habit: 3, 1 ✓. Weekly habit: 5, 1 ✓.
      expect(snapshot.total, 12);
      expect(snapshot.done, 3);
      expect(snapshot.percent, 25);
    });

    test('year hides trackers with too many columns', () {
      final snapshot = PlanSnapshot.build(
        goals: goals,
        period: PlanPeriod.year,
        anchor: wednesday,
        now: wednesday,
      );
      expect(snapshot.habitGroups, isEmpty);
      expect(snapshot.children, hasLength(12));
    });
  });

  test('task period survives toMap/fromMap', () {
    final task = GoalTask(
      id: 't',
      title: 'Plan',
      dueDate: saturday,
      period: PlanPeriod.week,
    );
    expect(GoalTask.fromMap(task.toMap()).planPeriod, PlanPeriod.week);
    final dayTask = GoalTask(id: 'd', title: 'Day', dueDate: saturday);
    expect(dayTask.toMap().containsKey('period'), isFalse);
    expect(GoalTask.fromMap(dayTask.toMap()).planPeriod, PlanPeriod.day);
  });
}
