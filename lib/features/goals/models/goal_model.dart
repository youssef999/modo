enum GoalStatus { active, done }

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
  final List<String> checkIns;
  final DateTime createdAt;
  final DateTime updatedAt;

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

  bool get isFullyComplete => isHabit ? completedDays >= plannedDays : isDone;

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
    List<String>? checkIns,
    DateTime? updatedAt,
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
      checkIns: checkIns ?? this.checkIns,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
      'checkIns': checkIns,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory GoalModel.fromMap(String id, Map<String, dynamic> data) {
    final dueAt =
        DateTime.tryParse(data['dueAt'] as String? ?? '') ?? DateTime.now();
    final createdAt =
        DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now();
    return GoalModel(
      id: id,
      ownerId: data['ownerId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      details: data['details'] as String? ?? '',
      kind: (data['kind'] as String?) == GoalKind.habit.name
          ? GoalKind.habit
          : GoalKind.once,
      startsAt:
          DateTime.tryParse(data['startsAt'] as String? ?? '') ?? createdAt,
      dueAt: dueAt,
      category: data['category'] as String? ?? 'course',
      status: (data['status'] as String?) == 'done'
          ? GoalStatus.done
          : GoalStatus.active,
      checkIns: _readCheckIns(data['checkIns']),
      createdAt: createdAt,
      updatedAt:
          DateTime.tryParse(data['updatedAt'] as String? ?? '') ?? createdAt,
    );
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
