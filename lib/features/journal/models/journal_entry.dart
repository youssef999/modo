class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.body,
    required this.day,
    required this.folderId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String title;
  final String body;
  final String day;
  final String folderId;
  final DateTime createdAt;
  final DateTime updatedAt;

  DateTime get dayDate => parseDay(day) ?? dateOnly(createdAt);

  String get displayTitle {
    if (title.trim().isNotEmpty) return title.trim();
    return titleFromBody(body);
  }

  String get preview {
    final text = body.trim();
    if (text.isEmpty) return '';
    return text;
  }

  JournalEntry copyWith({
    String? ownerId,
    String? title,
    String? body,
    String? day,
    String? folderId,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      body: body ?? this.body,
      day: day ?? this.day,
      folderId: folderId ?? this.folderId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'title': title,
      'body': body,
      'day': day,
      'folderId': folderId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory JournalEntry.fromMap(String id, Map<String, dynamic> data) {
    final createdAt =
        DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now();
    final body = data['body'] as String? ?? '';
    final rawTitle = (data['title'] as String? ?? '').trim();
    return JournalEntry(
      id: id,
      ownerId: data['ownerId'] as String? ?? '',
      title: rawTitle.isNotEmpty ? rawTitle : titleFromBody(body),
      body: body,
      day: (data['day'] as String?)?.trim().isNotEmpty == true
          ? data['day'] as String
          : dayKey(createdAt),
      folderId: (data['folderId'] as String?)?.trim().isNotEmpty == true
          ? data['folderId'] as String
          : 'general',
      createdAt: createdAt,
      updatedAt:
          DateTime.tryParse(data['updatedAt'] as String? ?? '') ?? createdAt,
    );
  }

  static String titleFromBody(String body) {
    final line = body.trim().split('\n').first.trim();
    if (line.isEmpty) return '';
    return line.length <= 120 ? line : line.substring(0, 120);
  }

  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String dayKey(DateTime date) {
    final value = dateOnly(date);
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  static DateTime? parseDay(String key) {
    final parts = key.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }

  static Map<String, List<JournalEntry>> groupByDay(List<JournalEntry> items) {
    final grouped = <String, List<JournalEntry>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.day, () => []).add(item);
    }
    for (final list in grouped.values) {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return grouped;
  }
}
