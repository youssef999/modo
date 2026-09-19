enum GoalTrackerKind { numeric, milestone, streak }

class GoalTracker {
  const GoalTracker({
    required this.id,
    required this.title,
    required this.kind,
    this.current = 0,
    this.target = 0,
    this.unit = '',
    this.milestones = const [],
    this.currentMilestoneIndex = 0,
  });

  final String id;
  final String title;
  final GoalTrackerKind kind;
  final double current;
  final double target;
  final String unit;
  final List<String> milestones;
  final int currentMilestoneIndex;

  double get progress {
    switch (kind) {
      case GoalTrackerKind.numeric:
        if (target <= 0) return current > 0 ? 1 : 0;
        return (current / target).clamp(0, 1);
      case GoalTrackerKind.milestone:
        if (milestones.isEmpty) return 0;
        return (currentMilestoneIndex / milestones.length).clamp(0, 1);
      case GoalTrackerKind.streak:
        if (target <= 0) return 1;
        return (current / target).clamp(0, 1);
    }
  }

  int get progressPercent => (progress * 100).round();

  bool get isCompleted => progress >= 1.0;

  GoalTracker copyWith({
    String? id,
    String? title,
    GoalTrackerKind? kind,
    double? current,
    double? target,
    String? unit,
    List<String>? milestones,
    int? currentMilestoneIndex,
  }) {
    return GoalTracker(
      id: id ?? this.id,
      title: title ?? this.title,
      kind: kind ?? this.kind,
      current: current ?? this.current,
      target: target ?? this.target,
      unit: unit ?? this.unit,
      milestones: milestones ?? this.milestones,
      currentMilestoneIndex:
          currentMilestoneIndex ?? this.currentMilestoneIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'kind': kind.name,
      'current': current,
      'target': target,
      'unit': unit,
      'milestones': milestones,
      'currentMilestoneIndex': currentMilestoneIndex,
    };
  }

  factory GoalTracker.fromMap(Map<String, dynamic> map) {
    final kindName = map['kind'] as String? ?? 'numeric';
    final kind = GoalTrackerKind.values.firstWhere(
      (k) => k.name == kindName,
      orElse: () => GoalTrackerKind.numeric,
    );

    return GoalTracker(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      kind: kind,
      current: (map['current'] as num?)?.toDouble() ?? 0,
      target: (map['target'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? '',
      milestones: (map['milestones'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      currentMilestoneIndex:
          (map['currentMilestoneIndex'] as num?)?.toInt() ?? 0,
    );
  }
}
