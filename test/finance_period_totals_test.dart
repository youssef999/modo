import 'package:flutter_test/flutter_test.dart';
import 'package:life_daily_app/features/finance/models/finance_category.dart';
import 'package:life_daily_app/features/finance/models/finance_entry.dart';
import 'package:life_daily_app/features/finance/models/finance_period_totals.dart';

void main() {
  final categories = FinanceCategory.builtIns('u1');

  FinanceEntry entry({
    required FinanceKind kind,
    required double amount,
    required DateTime at,
    String categoryId = 'food',
  }) {
    return FinanceEntry(
      id: '$kind$amount$categoryId${at.millisecondsSinceEpoch}',
      ownerId: 'u1',
      kind: kind,
      title: 'x',
      amount: amount,
      categoryId: categoryId,
      occurredAt: at,
      note: '',
      createdAt: at,
      updatedAt: at,
    );
  }

  test('period totals respect inclusive date range', () {
    final totals = FinancePeriodTotals.from(
      entries: [
        entry(
          kind: FinanceKind.expense,
          amount: 100,
          at: DateTime(2026, 8, 10),
        ),
        entry(
          kind: FinanceKind.expense,
          amount: 50,
          at: DateTime(2026, 8, 9),
        ),
        entry(
          kind: FinanceKind.expense,
          amount: 999,
          at: DateTime(2026, 8, 8),
        ),
        entry(
          kind: FinanceKind.salary,
          amount: 500,
          at: DateTime(2026, 8, 10),
          categoryId: 'salary',
        ),
        entry(
          kind: FinanceKind.expense,
          amount: 200,
          at: DateTime(2026, 8, 10),
          categoryId: 'savings',
        ),
      ],
      categories: categories,
      start: DateTime(2026, 8, 9),
      end: DateTime(2026, 8, 10),
    );
    expect(totals.spend, 150);
    expect(totals.income, 500);
    expect(totals.savings, 200);
    expect(totals.free, 350);
  });

  test('comparison percent ignores zero baseline', () {
    const comparison = FinancePeriodComparison(
      current: FinancePeriodTotals(
        income: 100,
        spend: 50,
        savings: 10,
        allocated: 10,
      ),
      previous: FinancePeriodTotals(
        income: 0,
        spend: 0,
        savings: 0,
        allocated: 0,
      ),
    );
    expect(comparison.percentChange(100, 0), isNull);
    expect(comparison.percentChange(50, 100), -50);
  });
}
