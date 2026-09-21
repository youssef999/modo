import 'package:life_daily_app/core/models/app_priority.dart';
import 'goal_sub_task.dart';

enum GoalTaskStatus { todo, inProgress, done }

class GoalTask {
  const GoalTask({
    required this.id,
    required this.title,
    GoalTaskStatus? status,
    bool? isCompleted,
    this.priority = AppPriority.medium,
    this.goalId,
    this.subtasks = const [],
    this.order = 0,
    this.assigneeId,
    this.assigneeEmail,
    this.assigneeName,
  }) : status = status ??
            (isCompleted == true ? GoalTaskStatus.done : GoalTaskStatus.todo);

  final String id;
  final String title;
  final GoalTaskStatus status;
  final AppPriority priority;
  final String? goalId;
  final List<GoalSubTask> subtasks;
  final int order;

  /// UID of the team member this task is assigned to.
  final String? assigneeId;

  /// Email of the assignee (for display without fetching member list).
  final String? assigneeEmail;

  /// Display name of the assignee.
  final String? assigneeName;

  bool get isCompleted =>
      status == GoalTaskStatus.done ||
      (subtasks.isNotEmpty && subtasks.every((s) => s.isCompleted));
  int get subtasksCompletedCount => subtasks.where((s) => s.isCompleted).length;
  double get subtasksProgress => subtasks.isEmpty
      ? (isCompleted ? 1.0 : 0.0)
      : subtasksCompletedCount / subtasks.length;
  int get subtasksProgressPercent => (subtasksProgress * 100).round();

  /// Initials for the assignee avatar (derived from assigneeName or assigneeEmail).
  String get assigneeInitials {
    final name = (assigneeName?.isNotEmpty == true)
        ? assigneeName!
        : (assigneeEmail ?? '');
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  GoalTask copyWith({
    String? id,
    String? title,
    GoalTaskStatus? status,
    bool? isCompleted,
    AppPriority? priority,
    String? goalId,
    List<GoalSubTask>? subtasks,
    int? order,
    String? assigneeId,
    String? assigneeEmail,
    String? assigneeName,
    bool clearAssignee = false,
  }) {
    final resolvedStatus = status ??
        (isCompleted != null
            ? (isCompleted ? GoalTaskStatus.done : GoalTaskStatus.todo)
            : this.status);
    return GoalTask(
      id: id ?? this.id,
      title: title ?? this.title,
      status: resolvedStatus,
      priority: priority ?? this.priority,
      goalId: goalId ?? this.goalId,
      subtasks: subtasks ?? this.subtasks,
      order: order ?? this.order,
      assigneeId: clearAssignee ? null : (assigneeId ?? this.assigneeId),
      assigneeEmail:
          clearAssignee ? null : (assigneeEmail ?? this.assigneeEmail),
      assigneeName: clearAssignee ? null : (assigneeName ?? this.assigneeName),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'status': status.name,
      'priority': priority.name,
      if (goalId != null) 'goalId': goalId,
      'subtasks': subtasks.map((s) => s.toMap()).toList(),
      'order': order,
      if (assigneeId != null) 'assigneeId': assigneeId,
      if (assigneeEmail != null) 'assigneeEmail': assigneeEmail,
      if (assigneeName != null) 'assigneeName': assigneeName,
    };
  }

  factory GoalTask.fromMap(Map<String, dynamic> map) {
    GoalTaskStatus parsedStatus = GoalTaskStatus.todo;
    if (map['status'] != null) {
      final s = map['status'] as String;
      if (s == 'done') {
        parsedStatus = GoalTaskStatus.done;
      } else if (s == 'inProgress') {
        parsedStatus = GoalTaskStatus.inProgress;
      }
    } else if (map['isCompleted'] == true) {
      parsedStatus = GoalTaskStatus.done;
    }

    final parsedPriority = AppPriority.fromName(map['priority'] as String?);
    final parsedGoalId = map['goalId'] as String?;

    final rawSubtasks = map['subtasks'];
    final parsedSubtasks = rawSubtasks is List
        ? rawSubtasks
            .whereType<Map<String, dynamic>>()
            .map(GoalSubTask.fromMap)
            .toList()
        : const <GoalSubTask>[];

    return GoalTask(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      status: parsedStatus,
      priority: parsedPriority,
      goalId: parsedGoalId,
      subtasks: parsedSubtasks,
      order: (map['order'] as num?)?.toInt() ?? 0,
      assigneeId: map['assigneeId'] as String?,
      assigneeEmail: map['assigneeEmail'] as String?,
      assigneeName: map['assigneeName'] as String?,
    );
  }
}
