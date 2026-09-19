class GoalTask {
  const GoalTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.order = 0,
  });

  final String id;
  final String title;
  final bool isCompleted;
  final int order;

  GoalTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    int? order,
  }) {
    return GoalTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'order': order,
    };
  }

  factory GoalTask.fromMap(Map<String, dynamic> map) {
    return GoalTask(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      isCompleted: map['isCompleted'] as bool? ?? false,
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }
}
