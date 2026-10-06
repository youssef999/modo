class FinanceCommitment {
  const FinanceCommitment({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.amount,
    required this.dueDay,
    this.isPaid = false,
    this.categoryId = '',
    this.note = '',
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String title;
  final double amount;
  final int dueDay;
  final bool isPaid;
  final String categoryId;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  FinanceCommitment copyWith({
    String? id,
    String? ownerId,
    String? title,
    double? amount,
    int? dueDay,
    bool? isPaid,
    String? categoryId,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FinanceCommitment(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dueDay: dueDay ?? this.dueDay,
      isPaid: isPaid ?? this.isPaid,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'amount': amount,
      'dueDay': dueDay,
      'isPaid': isPaid,
      'categoryId': categoryId,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FinanceCommitment.fromMap(String id, Map<String, dynamic> map) {
    return FinanceCommitment(
      id: id,
      ownerId: map['ownerId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      dueDay: (map['dueDay'] as num?)?.toInt() ?? 1,
      isPaid: map['isPaid'] as bool? ?? false,
      categoryId: map['categoryId'] as String? ?? '',
      note: map['note'] as String? ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
