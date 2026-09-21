class GoalSubTask {
  const GoalSubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.checkInDates = const [],
    this.dueDate,
    this.order = 0,
  });

  final String id;
  final String title;
  final bool isCompleted;
  final List<String> checkInDates;
  final DateTime? dueDate;
  final int order;

  static String dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool isCheckedOn(DateTime date) {
    return checkInDates.contains(dateKey(date));
  }

  GoalSubTask toggleDate(DateTime date) {
    final key = dateKey(date);
    final nextDates = List<String>.from(checkInDates);
    if (nextDates.contains(key)) {
      nextDates.remove(key);
    } else {
      nextDates.add(key);
    }
    return copyWith(checkInDates: nextDates);
  }

  GoalSubTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    List<String>? checkInDates,
    DateTime? dueDate,
    int? order,
  }) {
    return GoalSubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      checkInDates: checkInDates ?? this.checkInDates,
      dueDate: dueDate ?? this.dueDate,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'checkInDates': checkInDates,
      'dueDate': dueDate?.toIso8601String(),
      'order': order,
    };
  }

  factory GoalSubTask.fromMap(Map<String, dynamic> map) {
    return GoalSubTask(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      isCompleted: map['isCompleted'] as bool? ?? false,
      checkInDates: (map['checkInDates'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      dueDate: map['dueDate'] != null ? DateTime.tryParse(map['dueDate'].toString()) : null,
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }
}
