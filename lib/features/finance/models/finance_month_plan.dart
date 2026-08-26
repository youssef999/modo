class FinanceMonthPlan {
  const FinanceMonthPlan({
    required this.id,
    required this.ownerId,
    required this.yearMonth,
    required this.expectedSalary,
    required this.spendBudget,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String yearMonth;
  final double expectedSalary;
  final double spendBudget;
  final DateTime createdAt;
  final DateTime updatedAt;

  static String keyFor(DateTime month) {
    final value = DateTime(month.year, month.month);
    final mm = value.month.toString().padLeft(2, '0');
    return '${value.year}-$mm';
  }

  FinanceMonthPlan copyWith({
    String? ownerId,
    double? expectedSalary,
    double? spendBudget,
    DateTime? updatedAt,
  }) {
    return FinanceMonthPlan(
      id: id,
      ownerId: ownerId ?? this.ownerId,
      yearMonth: yearMonth,
      expectedSalary: expectedSalary ?? this.expectedSalary,
      spendBudget: spendBudget ?? this.spendBudget,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'yearMonth': yearMonth,
      'expectedSalary': expectedSalary,
      'spendBudget': spendBudget,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FinanceMonthPlan.fromMap(String id, Map<String, dynamic> data) {
    final createdAt =
        DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now();
    return FinanceMonthPlan(
      id: id,
      ownerId: data['ownerId'] as String? ?? '',
      yearMonth: data['yearMonth'] as String? ?? id,
      expectedSalary: (data['expectedSalary'] as num?)?.toDouble() ?? 0,
      spendBudget: (data['spendBudget'] as num?)?.toDouble() ?? 0,
      createdAt: createdAt,
      updatedAt:
          DateTime.tryParse(data['updatedAt'] as String? ?? '') ?? createdAt,
    );
  }
}
