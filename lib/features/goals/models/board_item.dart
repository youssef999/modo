import 'goal_model.dart';
import 'goal_task.dart';

/// A card on the unified tasks board: either a big task (goal) or a
/// standalone task from the General tasks inbox.
sealed class BoardItem {
  const BoardItem(this.goal);

  final GoalModel goal;

  String get key;
}

class GoalBoardItem extends BoardItem {
  const GoalBoardItem(super.goal);

  @override
  String get key => 'goal_${goal.id}';
}

class TaskBoardItem extends BoardItem {
  const TaskBoardItem(super.goal, this.task);

  final GoalTask task;

  @override
  String get key => 'task_${task.id}';
}
