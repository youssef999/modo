import 'package:life_daily_app/core/models/app_priority.dart';
import 'goal_member.dart';
import 'goal_task.dart';
import 'goal_tracker.dart';

enum GoalStatus {
  notStarted,
  inProgress,
  pending,
  done,
  archived;

  static const GoalStatus active = GoalStatus.notStarted;
}

enum GoalKind { once, habit }

class GoalModel {
  const GoalModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.details,
    required this.kind,
    required this.startsAt,
    required this.dueAt,
    required this.category,
    required this.status,
    required this.checkIns,
    required this.createdAt,
    required this.updatedAt,
    this.priority = AppPriority.medium,
    this.tasks = const [],
    this.trackers = const [],
    this.boardOrder = 0,
    this.members = const [],
    this.memberIds = const [],
    this.isInbox = false,
  });

  final String id;
  final String ownerId;
  final String title;
  final String details;
  final GoalKind kind;
  final DateTime startsAt;
  final DateTime dueAt;
  final String category;
  final GoalStatus status;
  final AppPriority priority;
  final List<String> checkIns;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<GoalTask> tasks;
  final List<GoalTracker> trackers;
  final int boardOrder;

  /// Team members for this goal (owner + partners).
  final List<GoalMember> members;

  /// List of UIDs with access to this goal (for Firestore queries).
  final List<String> memberIds;

  /// The hidden "General tasks" container for tasks without a goal.
  final bool isInbox;

  bool get isArchived => status == GoalStatus.archived;
  bool get isActive =>
      status == GoalStatus.notStarted ||
      status == GoalStatus.inProgress ||
      status == GoalStatus.pending;

  bool get isDone => status == GoalStatus.done;

  bool get isHabit => kind == GoalKind.habit;

  DateTime get rangeStart => dateOnly(startsAt);

  DateTime get rangeEnd => dateOnly(dueAt);

  int get plannedDays {
    final days = rangeEnd.difference(rangeStart).inDays + 1;
    return days < 1 ? 1 : days;
  }

  int get completedDays {
    return checkIns.toSet().where((key) {
      final day = parseDateKey(key);
      return day != null && containsDay(day);
    }).length;
  }

  double get progress {
    if (isHabit) {
      return (completedDays / plannedDays).clamp(0, 1);
    }
    return isDone ? 1 : 0;
  }

  int get progressPercent => (progress * 100).round();

  int get completedTasksCount => tasks.where((t) => t.isCompleted).length;

  double get taskCompletionRate {
    if (tasks.isEmpty) return 0.0;
    return (completedTasksCount / tasks.length).clamp(0, 1);
  }

  int get taskCompletionPercent => (taskCompletionRate * 100).round();

  double get trackerProgress {
    if (trackers.isEmpty) return 0.0;
    final sum = trackers.fold<double>(0.0, (acc, t) => acc + t.progress);
    return (sum / trackers.length).clamp(0, 1);
  }

  int get trackerProgressPercent => (trackerProgress * 100).round();

  double get overallSuccessRate {
    if (isHabit) {
      final components = <double>[progress];
      if (tasks.isNotEmpty) {
        components.add(taskCompletionRate);
      }
      if (trackers.isNotEmpty) {
        components.add(trackerProgress);
      }
      final sum = components.fold<double>(0.0, (acc, v) => acc + v);
      return (sum / components.length).clamp(0, 1);
    } else {
      if (isDone) return 1.0;
      final components = <double>[];
      if (tasks.isNotEmpty) {
        components.add(taskCompletionRate);
      }
      if (trackers.isNotEmpty) {
        components.add(trackerProgress);
      }
      if (components.isEmpty) return 0.0;
      final sum = components.fold<double>(0.0, (acc, v) => acc + v);
      return (sum / components.length).clamp(0, 1);
    }
  }

  int get overallSuccessPercent => (overallSuccessRate * 100).round();

  bool get isFullyComplete {
    if (isHabit) {
      return completedDays >= plannedDays;
    }
    return isDone || isArchived;
  }

  bool containsDay(DateTime day) {
    final value = dateOnly(day);
    return !value.isBefore(rangeStart) && !value.isAfter(rangeEnd);
  }

  bool canLog(DateTime day, {DateTime? now}) {
    final today = dateOnly(now ?? DateTime.now());
    final value = dateOnly(day);
    return isHabit && containsDay(value) && !value.isAfter(today);
  }

  bool isChecked(DateTime day) => checkIns.contains(dateKey(day));

  List<DateTime> recentDays({int count = 7, DateTime? now}) {
    final today = dateOnly(now ?? DateTime.now());
    var end = today.isAfter(rangeEnd) ? rangeEnd : today;
    if (end.isBefore(rangeStart)) {
      end = rangeStart.add(Duration(days: count - 1));
      if (end.isAfter(rangeEnd)) end = rangeEnd;
    }
    var start = end.subtract(Duration(days: count - 1));
    if (start.isBefore(rangeStart)) start = rangeStart;
    final days = <DateTime>[];
    for (
      var day = start;
      !day.isAfter(end);
      day = day.add(const Duration(days: 1))
    ) {
      days.add(day);
    }
    return days;
  }

  GoalModel copyWith({
    String? ownerId,
    String? title,
    String? details,
    GoalKind? kind,
    DateTime? startsAt,
    DateTime? dueAt,
    String? category,
    GoalStatus? status,
    AppPriority? priority,
    List<String>? checkIns,
    DateTime? updatedAt,
    List<GoalTask>? tasks,
    List<GoalTracker>? trackers,
    int? boardOrder,
    List<GoalMember>? members,
    List<String>? memberIds,
    bool? isInbox,
  }) {
    return GoalModel(
      id: id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      details: details ?? this.details,
      kind: kind ?? this.kind,
      startsAt: startsAt ?? this.startsAt,
      dueAt: dueAt ?? this.dueAt,
      category: category ?? this.category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      checkIns: checkIns ?? this.checkIns,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tasks: tasks ?? this.tasks,
      trackers: trackers ?? this.trackers,
      boardOrder: boardOrder ?? this.boardOrder,
      members: members ?? this.members,
      memberIds: memberIds ?? this.memberIds,
      isInbox: isInbox ?? this.isInbox,
    );
  }

  GoalModel prunedCheckIns() {
    final kept = checkIns.toSet().where((key) {
      final day = parseDateKey(key);
      return day != null && containsDay(day);
    }).toList()..sort();
    return copyWith(checkIns: kept);
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'title': title,
      'details': details,
      'kind': kind.name,
      'startsAt': startsAt.toIso8601String(),
      'dueAt': dueAt.toIso8601String(),
      'category': category,
      'status': status.name,
      'priority': priority.name,
      'checkIns': checkIns,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tasks': tasks.map((t) => t.toMap()).toList(),
      'trackers': trackers.map((t) => t.toMap()).toList(),
      'boardOrder': boardOrder,
      'memberIds': memberIds,
      'members': members.map((m) => m.toMap()).toList(),
      if (isInbox) 'isInbox': true,
    };
  }

  static GoalStatus _parseStatus(String? raw) {
    return switch (raw) {
      'done' => GoalStatus.done,
      'inProgress' => GoalStatus.inProgress,
      'pending' => GoalStatus.pending,
      'notStarted' => GoalStatus.notStarted,
      'archived' => GoalStatus.archived,
      'active' => GoalStatus.notStarted, // backward compat
      _ => GoalStatus.notStarted,
    };
  }

  factory GoalModel.fromMap(String id, Map<String, dynamic> data) {
    final dueAt = _parseDateValue(data['dueAt']);
    final createdAt = _parseDateValue(data['createdAt']);

    final rawTasks = data['tasks'];
    final tasksList = <GoalTask>[];
    if (rawTasks is List) {
      for (final item in rawTasks) {
        if (item is Map<String, dynamic>) {
          final task = GoalTask.fromMap(item);
          tasksList.add(task.goalId == null ? task.copyWith(goalId: id) : task);
        } else if (item is Map) {
          final task = GoalTask.fromMap(Map<String, dynamic>.from(item));
          tasksList.add(task.goalId == null ? task.copyWith(goalId: id) : task);
        }
      }
    }

    final rawTrackers = data['trackers'];
    final trackersList = <GoalTracker>[];
    if (rawTrackers is List) {
      for (final item in rawTrackers) {
        if (item is Map<String, dynamic>) {
          trackersList.add(GoalTracker.fromMap(item));
        } else if (item is Map) {
          trackersList.add(
            GoalTracker.fromMap(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final rawMembers = data['members'];
    final membersList = <GoalMember>[];
    if (rawMembers is List) {
      for (final item in rawMembers) {
        if (item is Map<String, dynamic>) {
          membersList.add(GoalMember.fromMap(item));
        } else if (item is Map) {
          membersList.add(GoalMember.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    }

    final rawMemberIds = data['memberIds'];
    final memberIdsList = rawMemberIds is List
        ? rawMemberIds.whereType<String>().toList()
        : const <String>[];

    return GoalModel(
      id: id,
      ownerId: data['ownerId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      details: data['details'] as String? ?? '',
      kind: (data['kind'] as String?) == GoalKind.habit.name
          ? GoalKind.habit
          : GoalKind.once,
      startsAt: _parseDateValue(data['startsAt'], createdAt),
      dueAt: dueAt,
      category: data['category'] as String? ?? 'course',
      status: _parseStatus(data['status'] as String?),
      priority: AppPriority.fromName(data['priority'] as String?),
      checkIns: _readCheckIns(data['checkIns']),
      createdAt: createdAt,
      updatedAt: _parseDateValue(data['updatedAt'], createdAt),
      tasks: tasksList,
      trackers: trackersList,
      boardOrder: (data['boardOrder'] as num?)?.toInt() ?? 0,
      members: membersList,
      memberIds: memberIdsList,
      isInbox: data['isInbox'] == true,
    );
  }

  static DateTime _parseDateValue(dynamic value, [DateTime? fallback]) {
    if (value is DateTime) return value;
    if (value != null && value is! String) {
      try {
        final dynamic d = value;
        final res = d.toDate();
        if (res is DateTime) return res;
      } catch (_) {}
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? fallback ?? DateTime.now();
    }
    return fallback ?? DateTime.now();
  }

  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String dateKey(DateTime date) {
    final value = dateOnly(date);
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  static DateTime? parseDateKey(String key) {
    final parts = key.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }

  static List<String> _readCheckIns(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<String>().toList();
  }
}
