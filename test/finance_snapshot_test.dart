import 'package:flutter_test/flutter_test.dart';
import 'package:life_daily_app/features/finance/models/finance_category.dart';
import 'package:life_daily_app/features/finance/models/finance_entry.dart';
import 'package:life_daily_app/features/finance/models/finance_month_plan.dart';
import 'package:life_daily_app/features/finance/models/finance_month_snapshot.dart';

void main() {
  final categories = FinanceCategory.builtIns('u1');
  final month = DateTime(2026, 8);

  FinanceEntry entry({
    required FinanceKind kind,
    required double amount,
    DateTime? at,
    String categoryId = 'food',
  }) {
    final day = at ?? DateTime(2026, 8, 10);
    return FinanceEntry(
      id: '$kind$amount$categoryId',
      ownerId: 'u1',
      kind: kind,
      title: 'x',
      amount: amount,
      categoryId: categoryId,
      occurredAt: day,
      note: '',
      createdAt: day,
      updatedAt: day,
    );
  }

  test('food spend cuts free; savings does not', () {
    final snapshot = FinanceMonthSnapshot.from(
      entries: [
        entry(kind: FinanceKind.salary, amount: 1000, at: DateTime(2026, 8, 1)),
        entry(kind: FinanceKind.expense, amount: 200, categoryId: 'food'),
        entry(kind: FinanceKind.expense, amount: 300, categoryId: 'savings'),
      ],
      categories: categories,
      month: month,
    );
    expect(snapshot.spend, 200);
    expect(snapshot.allocated, 300);
    expect(snapshot.free, 800);
    expect(snapshot.savings, 300);
  });

  test('month plan salary stays planned and is not counted as income', () {
    final snapshot = FinanceMonthSnapshot.from(
      entries: [
        entry(kind: FinanceKind.expense, amount: 100, categoryId: 'food'),
      ],
      categories: categories,
      month: month,
      plan: FinanceMonthPlan(
        id: '2026-08',
        ownerId: 'u1',
        yearMonth: '2026-08',
        expectedSalary: 2000,
        spendBudget: 0,
        createdAt: month,
        updatedAt: month,
      ),
    );
    expect(snapshot.income, 0);
    expect(snapshot.plannedIncome, 2000);
    expect(snapshot.free, -100);
  });

  test('income categories split logged pay', () {
    final snapshot = FinanceMonthSnapshot.from(
      entries: [
        entry(
          kind: FinanceKind.salary,
          amount: 1000,
          categoryId: 'salary',
          at: DateTime(2026, 8, 1),
        ),
        entry(
          kind: FinanceKind.income,
          amount: 200,
          categoryId: 'bonus',
          at: DateTime(2026, 8, 2),
        ),
      ],
      categories: categories,
      month: month,
    );
    expect(snapshot.income, 1200);
    expect(snapshot.incomeByCategory['salary'], 1000);
    expect(snapshot.incomeByCategory['bonus'], 200);
  });

  test('health uses spend budget when set', () {
    final plan = FinanceMonthPlan(
      id: '2026-08',
      ownerId: 'u1',
      yearMonth: '2026-08',
      expectedSalary: 5000,
      spendBudget: 1000,
      createdAt: month,
      updatedAt: month,
    );
    final good = FinanceMonthSnapshot.from(
      entries: [entry(kind: FinanceKind.expense, amount: 600)],
      categories: categories,
      month: month,
      plan: plan,
    );
    expect(good.health, FinanceHealth.good);

    final watch = FinanceMonthSnapshot.from(
      entries: [entry(kind: FinanceKind.expense, amount: 900)],
      categories: categories,
      month: month,
      plan: plan,
    );
    expect(watch.health, FinanceHealth.watch);

    final bad = FinanceMonthSnapshot.from(
      entries: [entry(kind: FinanceKind.expense, amount: 1200)],
      categories: categories,
      month: month,
      plan: plan,
    );
    expect(bad.health, FinanceHealth.bad);
  });

  test('salary vs living spend still drives health without a budget', () {
    final good = FinanceMonthSnapshot.from(
      entries: [
        entry(kind: FinanceKind.salary, amount: 1000, at: DateTime(2026, 8, 1)),
        entry(kind: FinanceKind.expense, amount: 200),
      ],
      categories: categories,
      month: month,
    );
    expect(good.health, FinanceHealth.good);
    expect(good.remaining, 800);
  });
}
