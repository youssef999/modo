import 'finance_category.dart';
import 'finance_entry.dart';

class FinancePeriodTotals {
  const FinancePeriodTotals({
    required this.income,
    required this.spend,
    required this.savings,
    required this.allocated,
  });

  factory FinancePeriodTotals.from({
    required List<FinanceEntry> entries,
    required List<FinanceCategory> categories,
    required DateTime start,
    required DateTime end,
  }) {
    final rangeStart = DateTime(start.year, start.month, start.day);
    final rangeEnd = DateTime(end.year, end.month, end.day);
    final byId = {for (final category in categories) category.id: category};
    var income = 0.0;
    var spend = 0.0;
    var savings = 0.0;
    var invested = 0.0;

    for (final entry in entries) {
      final day = DateTime(
        entry.occurredAt.year,
        entry.occurredAt.month,
        entry.occurredAt.day,
      );
      if (day.isBefore(rangeStart) || day.isAfter(rangeEnd)) continue;
      if (entry.isInflow) {
        income += entry.amount;
        continue;
      }
      if (!entry.isExpense) continue;
      final category = byId[entry.categoryId];
      if (category != null && category.isAllocate) {
        if (category.builtInKey == 'invest' || category.iconKey == 'invest') {
          invested += entry.amount;
        } else {
          savings += entry.amount;
        }
        continue;
      }
      spend += entry.amount;
    }

    return FinancePeriodTotals(
      income: income,
      spend: spend,
      savings: savings,
      allocated: savings + invested,
    );
  }

  factory FinancePeriodTotals.fromSnapshot({
    required double income,
    required double spend,
    required double savings,
    required double allocated,
  }) {
    return FinancePeriodTotals(
      income: income,
      spend: spend,
      savings: savings,
      allocated: allocated,
    );
  }

  final double income;
  final double spend;
  final double savings;
  final double allocated;

  double get free => income - spend;
}

class FinancePeriodComparison {
  const FinancePeriodComparison({
    required this.current,
    required this.previous,
  });

  final FinancePeriodTotals current;
  final FinancePeriodTotals previous;

  int? percentChange(double current, double previous) {
    if (previous == 0) return null;
    return (((current - previous) / previous) * 100).round();
  }

  bool isIncrease(double current, double previous) => current > previous;

  bool isSame(double current, double previous) => current == previous;
}
