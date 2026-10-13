import 'goal_model.dart';
import 'goal_task.dart';
import 'plan_period.dart';

/// Which slice of goals and tasks the board shows: one day / week / month /
/// year around [anchor], or the general items that have no period.
class BoardScope {
  BoardScope({this.period, DateTime? anchor})
    : anchor = GoalModel.dateOnly(anchor ?? DateTime.now());

  /// `null` = General.
  final PlanPeriod? period;
  final DateTime anchor;

  bool get isGeneral => period == null;

  DateTime get start => period?.startOf(anchor) ?? anchor;
  DateTime get end => period?.endOf(anchor) ?? anchor;

  bool isCurrent({DateTime? now}) {
    final p = period;
    return p == null || p.contains(anchor, now ?? DateTime.now());
  }

  BoardScope withPeriod(PlanPeriod? next) =>
      BoardScope(period: next, anchor: anchor);

  BoardScope shift(int count) {
    final p = period;
    if (p == null) return this;
    return BoardScope(period: p, anchor: p.shift(anchor, count));
  }

  BoardScope toNow({DateTime? now}) => BoardScope(period: period, anchor: now);

  bool _within(DateTime date) {
    final day = GoalModel.dateOnly(date);
    return !day.isBefore(start) && !day.isAfter(end);
  }

  /// Viewing today's Daily board, where unfinished late items also show.
  bool _showsOverdue(DateTime today) =>
      period == PlanPeriod.day && anchor == today;

  bool includesGoal(GoalModel goal, {DateTime? now}) {
    if (goal.isInbox || goal.isArchived) return false;
    final p = period;
    if (p == null) return goal.planPeriod == null;
    if (goal.planPeriod != p) return false;
    if (goal.isHabit) {
      return !goal.rangeEnd.isBefore(start) && !goal.rangeStart.isAfter(end);
    }
    if (_within(goal.dueAt)) return true;
    final today = GoalModel.dateOnly(now ?? DateTime.now());
    return _showsOverdue(today) &&
        !goal.isDone &&
        goal.rangeEnd.isBefore(today);
  }

  /// Tasks shown as their own cards. Undated tasks of a real goal stay
  /// inside that goal's card instead.
  bool includesTask(GoalModel goal, GoalTask task, {DateTime? now}) {
    if (goal.isArchived) return false;
    final due = task.dueDate;
    final p = period;
    if (p == null) return goal.isInbox && due == null;
    if (due == null || task.planPeriod != p) return false;
    if (_within(due)) return true;
    return isOverdue(task, now: now) &&
        _showsOverdue(GoalModel.dateOnly(now ?? DateTime.now()));
  }

  static bool isOverdue(GoalTask task, {DateTime? now}) {
    final due = task.dueDate;
    if (due == null || task.isCompleted) return false;
    final today = GoalModel.dateOnly(now ?? DateTime.now());
    final end = task.planPeriod.endOf(due);
    return end.isBefore(today);
  }
}
