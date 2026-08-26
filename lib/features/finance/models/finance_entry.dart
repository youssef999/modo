enum FinanceKind { expense, salary, income }

class FinanceEntry {
  const FinanceEntry({
    required this.id,
    required this.ownerId,
    required this.kind,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.occurredAt,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;
  final FinanceKind kind;
  final String title;
  final double amount;
  final String categoryId;
  final DateTime occurredAt;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isInflow => kind == FinanceKind.salary || kind == FinanceKind.income;

  bool get isExpense => kind == FinanceKind.expense;

  FinanceEntry copyWith({String? ownerId, DateTime? updatedAt}) {
    return FinanceEntry(
      id: id,
      ownerId: ownerId ?? this.ownerId,
      kind: kind,
      title: title,
      amount: amount,
      categoryId: categoryId,
      occurredAt: occurredAt,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'kind': kind.name,
      'title': title,
      'amount': amount,
      'categoryId': categoryId,
      'occurredAt': occurredAt.toIso8601String(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FinanceEntry.fromMap(String id, Map<String, dynamic> data) {
    final createdAt =
        DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now();
    return FinanceEntry(
      id: id,
      ownerId: data['ownerId'] as String? ?? '',
      kind: FinanceEntry.kindFrom(data['kind'] as String?),
      title: data['title'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      categoryId: data['categoryId'] as String? ?? '',
      occurredAt:
          DateTime.tryParse(data['occurredAt'] as String? ?? '') ?? createdAt,
      note: data['note'] as String? ?? '',
      createdAt: createdAt,
      updatedAt:
          DateTime.tryParse(data['updatedAt'] as String? ?? '') ?? createdAt,
    );
  }

  static FinanceKind kindFrom(String? value) {
    return switch (value) {
      'salary' => FinanceKind.salary,
      'income' => FinanceKind.income,
      _ => FinanceKind.expense,
    };
  }
}
