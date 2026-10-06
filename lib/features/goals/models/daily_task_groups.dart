import 'goal_model.dart';
import 'goal_task.dart';

typedef GoalTaskEntry = ({GoalModel goal, GoalTask task});

/// Tasks shown on a day, split by how they relate to that day.
class DailyTaskGroups {
  const DailyTaskGroups({
    this.overdue = const [],
    this.scheduled = const [],
    this.anytime = const [],
  });

  /// Open tasks due before today (only filled when viewing today).
  final List<GoalTaskEntry> overdue;

  /// Tasks due on the viewed day.
  final List<GoalTaskEntry> scheduled;

  /// Tasks without a due date (only filled when viewing today).
  final List<GoalTaskEntry> anytime;

  List<GoalTaskEntry> get all => [...overdue, ...scheduled, ...anytime];

  int get total => overdue.length + scheduled.length + anytime.length;

  bool get isEmpty => total == 0;
}
