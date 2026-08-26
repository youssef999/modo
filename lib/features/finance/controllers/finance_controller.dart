import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/features/auth/services/i_auth_service.dart';

import '../models/finance_category.dart';
import '../models/finance_category_role.dart';
import '../models/finance_entry.dart';
import '../models/finance_month_plan.dart';
import '../models/finance_month_snapshot.dart';
import '../models/finance_period_totals.dart';
import '../repositories/i_finance_repository.dart';

enum FinancePageTab { charts, reports }

enum FinanceChartKind { expense, income }

class FinanceController extends GetxController {
  FinanceController(this._repository);

  final IFinanceRepository _repository;

  List<FinanceCategory> categories = [];
  List<FinanceEntry> entries = [];
  List<FinanceMonthPlan> monthPlans = [];
  String? selectedCategoryId;
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  FinancePageTab pageTab = FinancePageTab.charts;
  FinanceChartKind chartKind = FinanceChartKind.expense;
  bool isLoading = true;

  String get ownerId => Get.find<IAuthService>().currentUser?.uid ?? '';

  FinanceMonthSnapshot get snapshot {
    return FinanceMonthSnapshot.from(
      entries: entries,
      categories: categories,
      month: month,
      plan: planFor(month),
    );
  }

  FinancePeriodComparison get weekComparison {
    final end = _weekComparisonEnd;
    final currentStart = end.subtract(const Duration(days: 6));
    final previousEnd = currentStart.subtract(const Duration(days: 1));
    final previousStart = previousEnd.subtract(const Duration(days: 6));
    return FinancePeriodComparison(
      current: _periodTotals(currentStart, end),
      previous: _periodTotals(previousStart, previousEnd),
    );
  }

  FinancePeriodComparison get monthComparison {
    final previousMonth = DateTime(month.year, month.month - 1);
    final previousSnapshot = FinanceMonthSnapshot.from(
      entries: entries,
      categories: categories,
      month: previousMonth,
      plan: planFor(previousMonth),
    );
    final current = snapshot;
    return FinancePeriodComparison(
      current: FinancePeriodTotals.fromSnapshot(
        income: current.income,
        spend: current.spend,
        savings: current.savings,
        allocated: current.allocated,
      ),
      previous: FinancePeriodTotals.fromSnapshot(
        income: previousSnapshot.income,
        spend: previousSnapshot.spend,
        savings: previousSnapshot.savings,
        allocated: previousSnapshot.allocated,
      ),
    );
  }

  DateTime get _weekComparisonEnd {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isCurrentMonth = month.year == now.year && month.month == now.month;
    if (isCurrentMonth) return today;
    return DateTime(month.year, month.month + 1, 0);
  }

  List<FinanceEntry> get visibleEntries {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    return entries.where((entry) {
      final day = DateTime(
        entry.occurredAt.year,
        entry.occurredAt.month,
        entry.occurredAt.day,
      );
      if (day.isBefore(start) || !day.isBefore(end)) return false;
      return true;
    }).toList();
  }

  List<FinanceCategory> get spendCategories {
    return categories.where((item) => !item.isIncome).toList();
  }

  List<FinanceCategory> get incomeCategories {
    return categories.where((item) => item.isIncome).toList();
  }

  bool get hasActivity => entries.isNotEmpty;

  static String formatAmount(double value) {
    return FinanceMonthSnapshot.format(value);
  }

  FinanceMonthPlan planFor(DateTime target) {
    final key = FinanceMonthPlan.keyFor(target);
    for (final plan in monthPlans) {
      if (plan.yearMonth == key) return plan;
    }
    final previous = [...monthPlans]
      ..sort((a, b) => b.yearMonth.compareTo(a.yearMonth));
    FinanceMonthPlan? seed;
    for (final plan in previous) {
      if (plan.yearMonth.compareTo(key) < 0) {
        seed = plan;
        break;
      }
    }
    final now = DateTime.now();
    return FinanceMonthPlan(
      id: key,
      ownerId: ownerId,
      yearMonth: key,
      expectedSalary: seed?.expectedSalary ?? 0,
      spendBudget: seed?.spendBudget ?? 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading = true;
    update(['finance']);
    if (ownerId.isEmpty) {
      isLoading = false;
      update(['finance']);
      return;
    }
    categories = await _repository.fetchCategories(ownerId);
    entries = await _repository.fetchEntries(ownerId);
    monthPlans = await _repository.fetchMonthPlans(ownerId);
    await _ensureCarriedPlan();
    isLoading = false;
    update(['finance']);
  }

  Future<void> onAccountReady() async {
    await _repository.syncAfterLogin(ownerId);
    await load();
  }

  void selectCategory(String? id) {
    selectedCategoryId = selectedCategoryId == id ? null : id;
    update(['finance']);
  }

  void previousMonth() {
    month = DateTime(month.year, month.month - 1);
    _ensureCarriedPlan();
    update(['finance']);
  }

  void nextMonth() {
    month = DateTime(month.year, month.month + 1);
    _ensureCarriedPlan();
    update(['finance']);
  }

  void selectMonth(DateTime value) {
    month = DateTime(value.year, value.month);
    _ensureCarriedPlan();
    update(['finance']);
  }

  void selectPageTab(FinancePageTab value) {
    pageTab = value;
    update(['finance']);
  }

  void selectChartKind(FinanceChartKind value) {
    chartKind = value;
    update(['finance']);
  }

  List<DateTime> nearbyMonths({int count = 7}) {
    final now = DateTime(DateTime.now().year, DateTime.now().month);
    return [
      for (var offset = 0; offset < count; offset++)
        DateTime(now.year, now.month + offset),
    ];
  }

  String categoryLabel(FinanceCategory category) {
    if (category.isBuiltIn) return category.labelKey.tr;
    return category.name;
  }

  String entryLabel(FinanceEntry entry) {
    if (entry.title.isNotEmpty) return entry.title;
    final category = categoryById(
      entry.categoryId.trim().isEmpty && entry.isInflow
          ? 'salary'
          : entry.categoryId,
    );
    if (category != null) return categoryLabel(category);
    if (entry.kind == FinanceKind.salary) return LocaleKeys.financeSalary.tr;
    return LocaleKeys.financeTitle.tr;
  }

  FinanceCategory? categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  Future<String?> addCategory(
    String name, {
    FinanceCategoryRole role = FinanceCategoryRole.spend,
    String iconKey = 'star',
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;
    final category = await _repository.addCategory(
      ownerId: ownerId,
      name: trimmed,
      role: role,
      iconKey: iconKey,
    );
    categories = [...categories, category];
    selectedCategoryId = category.id;
    update(['finance']);
    return category.id;
  }

  Future<void> addExpense({
    required double amount,
    required String categoryId,
    required DateTime occurredAt,
    required String note,
  }) async {
    if (amount <= 0 || categoryId.isEmpty) return;
    final category = categoryById(categoryId);
    final title = note.trim().isEmpty
        ? (category == null
              ? LocaleKeys.financeTitle.tr
              : categoryLabel(category))
        : note.trim();
    final entry = await _repository.addEntry(
      ownerId: ownerId,
      kind: FinanceKind.expense,
      title: title,
      amount: amount,
      categoryId: categoryId,
      occurredAt: occurredAt,
      note: note,
    );
    entries = [entry, ...entries];
    update(['finance']);
  }

  Future<void> addIncome({
    required double amount,
    required String categoryId,
    required DateTime occurredAt,
    required String note,
  }) async {
    if (amount <= 0 || categoryId.isEmpty) return;
    final category = categoryById(categoryId);
    final title = note.trim().isEmpty
        ? (category == null
              ? LocaleKeys.financeIncome.tr
              : categoryLabel(category))
        : note.trim();
    final kind = category?.builtInKey == 'salary'
        ? FinanceKind.salary
        : FinanceKind.income;
    final entry = await _repository.addEntry(
      ownerId: ownerId,
      kind: kind,
      title: title,
      amount: amount,
      categoryId: categoryId,
      occurredAt: occurredAt,
      note: note,
    );
    entries = [entry, ...entries];
    update(['finance']);
  }

  Future<void> addSalary({
    required double amount,
    required DateTime occurredAt,
    required String note,
  }) {
    return addIncome(
      amount: amount,
      categoryId: 'salary',
      occurredAt: occurredAt,
      note: note,
    );
  }

  Future<void> saveMonthPlan({
    required double expectedSalary,
    required double spendBudget,
  }) async {
    final existing = planFor(month);
    final now = DateTime.now();
    final plan = existing.copyWith(
      ownerId: ownerId,
      expectedSalary: expectedSalary,
      spendBudget: spendBudget,
      updatedAt: now,
    );
    final saved = await _repository.saveMonthPlan(plan);
    monthPlans = [
      for (final item in monthPlans)
        if (item.id != saved.id) item,
      saved,
    ];
    update(['finance']);
  }

  Future<void> deleteEntry(FinanceEntry entry) async {
    await _repository.deleteEntry(ownerId, entry.id);
    entries = entries.where((item) => item.id != entry.id).toList();
    update(['finance']);
  }

  FinancePeriodTotals _periodTotals(DateTime start, DateTime end) {
    return FinancePeriodTotals.from(
      entries: entries,
      categories: categories,
      start: start,
      end: end,
    );
  }

  Future<void> _ensureCarriedPlan() async {
    if (ownerId.isEmpty) return;
    final key = FinanceMonthPlan.keyFor(month);
    final exists = monthPlans.any((item) => item.yearMonth == key);
    if (exists) return;
    final draft = planFor(month);
    if (draft.expectedSalary <= 0 && draft.spendBudget <= 0) return;
    final saved = await _repository.saveMonthPlan(draft);
    monthPlans = [...monthPlans, saved];
  }
}
