enum WorkStatus { open, done }

class WorkItem {
  const WorkItem({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.details,
    required this.folderId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String title;
  final String details;
  final String folderId;
  final WorkStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDone => status == WorkStatus.done;

  WorkItem copyWith({
    String? ownerId,
    String? title,
    String? details,
    String? folderId,
    WorkStatus? status,
    DateTime? updatedAt,
  }) {
    return WorkItem(
      id: id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      details: details ?? this.details,
      folderId: folderId ?? this.folderId,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'title': title,
      'details': details,
      'folderId': folderId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory WorkItem.fromMap(String id, Map<String, dynamic> data) {
    final createdAt =
        DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now();
    return WorkItem(
      id: id,
      ownerId: data['ownerId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      details: data['details'] as String? ?? '',
      folderId: (data['folderId'] as String?)?.trim().isNotEmpty == true
          ? data['folderId'] as String
          : 'general',
      status: (data['status'] as String?) == WorkStatus.done.name
          ? WorkStatus.done
          : WorkStatus.open,
      createdAt: createdAt,
      updatedAt:
          DateTime.tryParse(data['updatedAt'] as String? ?? '') ?? createdAt,
    );
  }

  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
