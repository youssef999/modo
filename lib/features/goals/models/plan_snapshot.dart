import 'daily_task_groups.dart';
import 'goal_model.dart';
import 'plan_period.dart';

/// One repetition of a habit inside a plan view.
class PlanHabitCell {
  const PlanHabitCell({
    required this.start,
    required this.checked,
    required this.inRange,
    required this.canLog,
  });

  final DateTime start;
  final bool checked;
  final bool inRange;
  final bool canLog;
}

class PlanHabitRow {
  const PlanHabitRow({required this.habit, required this.cells});

  final GoalModel habit;
  final List<PlanHabitCell> cells;

  int get done => cells.where((c) => c.checked && c.inRange).length;
  int get total => cells.where((c) => c.inRange).length;
  double get progress => total == 0 ? 0 : done / total;
}

/// Habits sharing one repeat, laid out against that repeat's columns.
class PlanHabitGroup {
  const PlanHabitGroup({
    required this.repeat,
    required this.columns,
    required this.rows,
  });

  final PlanPeriod repeat;
  final List<DateTime> columns;
  final List<PlanHabitRow> rows;
}

/// A smaller period inside the viewed one (a day of a week, …).
class PlanChild {
  const PlanChild({
    required this.start,
    required this.tasks,
    required this.done,
    required this.total,
  });

  final DateTime start;

  /// Tasks planned for exactly this child period.
  final List<GoalTaskEntry> tasks;
  final int done;
  final int total;

  double get progress => total == 0 ? 0 : done / total;
}

/// Everything a Week / Month / Year view shows, with its progress.
///
/// Progress counts every task planned inside the period (its own and its
/// smaller periods') plus every habit repetition shown in its tracker.
class PlanSnapshot {
  const PlanSnapshot({
    required this.period,
    required this.start,
    required this.end,
    required this.tasks,
    required this.habitGroups,
    required this.children,
    required this.done,
    required this.total,
  });

  /// More columns than this make a tracker row unreadable (daily habits in a
  /// year view), so such groups are left out of that view.
  static const int maxColumns = 31;

  final PlanPeriod period;
  final DateTime start;
  final DateTime end;
  final List<GoalTaskEntry> tasks;
  final List<PlanHabitGroup> habitGroups;
  final List<PlanChild> children;
  final int done;
  final int total;

  double get progress => total == 0 ? 0 : done / total;
  int get percent => (progress * 100).round();

  factory PlanSnapshot.build({
    required List<GoalModel> goals,
    required PlanPeriod period,
    required DateTime anchor,
    DateTime? now,
  }) {
    final today = GoalModel.dateOnly(now ?? DateTime.now());
    final active = goals.where((g) => !g.isArchived).toList();
    final start = period.startOf(anchor);
    final end = period.endOf(start);
    final groups = _habitGroups(active, period, start, end, today);
    final tally = _tally(active, period, start, end, groups);

    final child = period.breakdown;
    final children = <PlanChild>[
      if (child != null)
        for (final childStart in child.startsBetween(start, end))
          _child(active, child, childStart, today),
    ];

    return PlanSnapshot(
      period: period,
      start: start,
      end: end,
      tasks: _tasksFor(active, period, start, end),
      habitGroups: groups,
      children: children,
      done: tally.done,
      total: tally.total,
    );
  }

  static PlanChild _child(
    List<GoalModel> goals,
    PlanPeriod period,
    DateTime start,
    DateTime today,
  ) {
    final end = period.endOf(start);
    final groups = _habitGroups(goals, period, start, end, today);
    final tally = _tally(goals, period, start, end, groups);
    return PlanChild(
      start: start,
      tasks: _tasksFor(goals, period, start, end),
      done: tally.done,
      total: tally.total,
    );
  }

  static bool _within(DateTime date, DateTime start, DateTime end) {
    final day = GoalModel.dateOnly(date);
    return !day.isBefore(start) && !day.isAfter(end);
  }

  static List<GoalTaskEntry> _tasksFor(
    List<GoalModel> goals,
    PlanPeriod period,
    DateTime start,
    DateTime end,
  ) {
    final entries = <GoalTaskEntry>[
      for (final goal in goals)
        for (final task in goal.tasks)
          if (task.dueDate != null &&
              task.planPeriod == period &&
              _within(task.dueDate!, start, end))
            (goal: goal, task: task),
    ];
    entries.sort((a, b) {
      if (a.task.isCompleted == b.task.isCompleted) return 0;
      return a.task.isCompleted ? 1 : -1;
    });
    return entries;
  }

  static List<PlanHabitGroup> _habitGroups(
    List<GoalModel> goals,
    PlanPeriod period,
    DateTime start,
    DateTime end,
    DateTime today,
  ) {
    final groups = <PlanHabitGroup>[];
    for (final repeat in PlanPeriod.values) {
      if (repeat.index > period.index) break;
      final columns = repeat.startsBetween(start, end);
      if (columns.length > maxColumns) continue;
      final rows = <PlanHabitRow>[];
      for (final habit in goals) {
        if (!habit.isHabit || habit.repeat != repeat) continue;
        final cells = [
          for (final column in columns)
            PlanHabitCell(
              start: column,
              checked: habit.isChecked(column),
              inRange: habit.overlapsPeriodOf(column),
              canLog: habit.canLog(column, now: today),
            ),
        ];
        if (cells.any((c) => c.inRange)) {
          rows.add(PlanHabitRow(habit: habit, cells: cells));
        }
      }
      if (rows.isNotEmpty) {
        groups.add(
          PlanHabitGroup(repeat: repeat, columns: columns, rows: rows),
        );
      }
    }
    return groups;
  }

  static ({int done, int total}) _tally(
    List<GoalModel> goals,
    PlanPeriod period,
    DateTime start,
    DateTime end,
    List<PlanHabitGroup> groups,
  ) {
    var done = 0;
    var total = 0;
    for (final goal in goals) {
      for (final task in goal.tasks) {
        final due = task.dueDate;
        if (due == null ||
            task.planPeriod.index > period.index ||
            !_within(due, start, end)) {
          continue;
        }
        total++;
        if (task.isCompleted) done++;
      }
    }
    for (final group in groups) {
      for (final row in group.rows) {
        done += row.done;
        total += row.total;
      }
    }
    return (done: done, total: total);
  }
}
