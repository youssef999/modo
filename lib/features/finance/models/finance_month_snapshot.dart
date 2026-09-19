import 'finance_category.dart';
import 'finance_commitment.dart';
import 'finance_entry.dart';
import 'finance_month_plan.dart';

enum FinanceHealth { unknown, good, watch, bad }

class FinanceMonthSnapshot {
  const FinanceMonthSnapshot({
    required this.income,
    required this.plannedIncome,
    required this.spend,
    required this.allocated,
    required this.savings,
    required this.invested,
    required this.spendBudget,
    required this.byCategory,
    required this.outflowByCategory,
    required this.incomeByCategory,
    required this.dailySpend,
    this.commitmentsTotal = 0.0,
    this.unpaidCommitments = 0.0,
    this.paidCommitments = 0.0,
  });

  factory FinanceMonthSnapshot.from({
    required List<FinanceEntry> entries,
    required List<FinanceCategory> categories,
    required DateTime month,
    FinanceMonthPlan? plan,
    List<FinanceCommitment> commitments = const [],
  }) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    var loggedIncome = 0.0;
    var spend = 0.0;
    var savings = 0.0;
    var invested = 0.0;
    final byId = {for (final category in categories) category.id: category};
    final spendMap = <String, double>{
      for (final category in categories)
        if (category.isSpend) category.id: 0,
    };
    final outflowMap = <String, double>{
      for (final category in categories)
        if (!category.isIncome) category.id: 0,
    };
    final incomeMap = <String, double>{
      for (final category in categories)
        if (category.isIncome) category.id: 0,
    };
    final daily = List<double>.filled(daysInMonth, 0);

    for (final entry in entries) {
      final day = DateTime(
        entry.occurredAt.year,
        entry.occurredAt.month,
        entry.occurredAt.day,
      );
      if (day.isBefore(start) || !day.isBefore(end)) continue;
      if (entry.isInflow) {
        loggedIncome += entry.amount;
        final incomeId = entry.categoryId.trim().isNotEmpty
            ? entry.categoryId
            : 'salary';
        incomeMap[incomeId] = (incomeMap[incomeId] ?? 0) + entry.amount;
        continue;
      }
      if (!entry.isExpense) continue;
      final category = byId[entry.categoryId];
      if (category != null && !category.isIncome) {
        outflowMap[category.id] = (outflowMap[category.id] ?? 0) + entry.amount;
      }
      if (category != null && category.isAllocate) {
        if (category.builtInKey == 'invest' || category.iconKey == 'invest') {
          invested += entry.amount;
        } else {
          savings += entry.amount;
        }
        continue;
      }
      spend += entry.amount;
      spendMap[entry.categoryId] =
          (spendMap[entry.categoryId] ?? 0) + entry.amount;
      final index = entry.occurredAt.day - 1;
      if (index >= 0 && index < daily.length) {
        daily[index] += entry.amount;
      }
    }

    var totalCommitments = 0.0;
    var unpaid = 0.0;
    var paid = 0.0;
    for (final item in commitments) {
      totalCommitments += item.amount;
      if (item.isPaid) {
        paid += item.amount;
      } else {
        unpaid += item.amount;
      }
    }

    return FinanceMonthSnapshot(
      income: loggedIncome,
      plannedIncome: plan?.expectedSalary ?? 0,
      spend: spend,
      allocated: savings + invested,
      savings: savings,
      invested: invested,
      spendBudget: plan?.spendBudget ?? 0,
      byCategory: spendMap,
      outflowByCategory: outflowMap,
      incomeByCategory: incomeMap,
      dailySpend: daily,
      commitmentsTotal: totalCommitments,
      unpaidCommitments: unpaid,
      paidCommitments: paid,
    );
  }

  final double income;
  final double plannedIncome;
  final double spend;
  final double allocated;
  final double savings;
  final double invested;
  final double spendBudget;
  final Map<String, double> byCategory;
  final Map<String, double> outflowByCategory;
  final Map<String, double> incomeByCategory;
  final List<double> dailySpend;
  final double commitmentsTotal;
  final double unpaidCommitments;
  final double paidCommitments;

  double get expenses => spend;

  double get remaining => free;

  double get free => income - spend;

  double get safeLiquidity => free - unpaidCommitments;

  double get safeRemaining => safeLiquidity;

  double get budgetLeft => spendBudget - spend;

  double get savingsRate {
    if (income <= 0) return 0;
    return (savings / income).clamp(0, 1);
  }

  int get savingsPercent => (savingsRate * 100).round();

  double get reference {
    if (spendBudget > 0) return spendBudget;
    return income;
  }

  double get spentRatio => reference <= 0 ? 0 : spend / reference;

  int get spentPercent =>
      reference <= 0 ? 0 : (spentRatio * 100).round().clamp(0, 999);

  FinanceHealth get health {
    if (reference <= 0) return FinanceHealth.unknown;
    if (spentRatio <= 0.7) return FinanceHealth.good;
    if (spentRatio <= 1) return FinanceHealth.watch;
    return FinanceHealth.bad;
  }

  static String format(double value) {
    final rounded = value.roundToDouble();
    if (rounded == value) return value.round().toString();
    return value.toStringAsFixed(2);
  }
}
