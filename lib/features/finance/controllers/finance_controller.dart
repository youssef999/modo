import 'dart:convert';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/constants/storage_keys.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';
import 'package:life_daily_app/features/auth/services/i_auth_service.dart';

import '../models/finance_category.dart';
import '../models/finance_category_role.dart';
import '../models/finance_commitment.dart';
import '../models/finance_entry.dart';
import '../models/finance_month_plan.dart';
import '../models/finance_month_snapshot.dart';
import '../models/finance_period_totals.dart';
import '../repositories/i_finance_repository.dart';

enum FinancePageTab { charts, reports }

enum FinanceChartKind { expense, income }

/// Money is tracked per day; month is a secondary roll-up view.
enum FinancePeriod { day, month }

class FinanceController extends GetxController {
  FinanceController(this._repository, [IStorage? storage])
    : _storage =
          storage ??
          (Get.isRegistered<IStorage>() ? Get.find<IStorage>() : null);

  final IFinanceRepository _repository;
  final IStorage? _storage;

  List<FinanceCategory> categories = [];
  List<FinanceEntry> entries = [];
  List<FinanceMonthPlan> monthPlans = [];
  List<FinanceCommitment> commitments = [];
  String? selectedCategoryId;
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  FinancePageTab pageTab = FinancePageTab.charts;
  FinanceChartKind chartKind = FinanceChartKind.expense;
  FinancePeriod period = FinancePeriod.day;
  DateTime selectedDay = _today();
  DateTime _dayWindowEnd = _today();
  bool isLoading = true;

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool get isDayView => period == FinancePeriod.day;

  bool get isSelectedToday => _sameDay(selectedDay, _today());

  static bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Seven days ending at the current window end (today by default).
  List<DateTime> nearbyDays() {
    return [
      for (var offset = 6; offset >= 0; offset--)
        DateTime(
          _dayWindowEnd.year,
          _dayWindowEnd.month,
          _dayWindowEnd.day - offset,
        ),
    ];
  }

  bool get canShiftDaysForward => _dayWindowEnd.isBefore(_today());

  void shiftDays(int direction) {
    var end = DateTime(
      _dayWindowEnd.year,
      _dayWindowEnd.month,
      _dayWindowEnd.day + 7 * direction,
    );
    final today = _today();
    if (end.isAfter(today)) end = today;
    _dayWindowEnd = end;
    final days = nearbyDays();
    if (!days.any((day) => _sameDay(day, selectedDay))) {
      _setDay(direction > 0 ? days.first : days.last);
    }
    update(['finance']);
  }

  void selectDay(DateTime value) {
    _setDay(value);
    update(['finance']);
  }

  void goToToday() {
    _dayWindowEnd = _today();
    _setDay(_today());
    update(['finance']);
  }

  void _setDay(DateTime value) {
    selectedDay = DateTime(value.year, value.month, value.day);
    month = DateTime(value.year, value.month);
    _ensureCarriedPlan();
  }

  void selectPeriod(FinancePeriod value) {
    if (period == value) return;
    period = value;
    update(['finance']);
  }

  double get selectedDaySpend => dailySpendForDate(selectedDay);

  double get selectedDayIncome => dailyIncomeForDate(selectedDay);

  /// Defaults new entries to the day being viewed, keeping the current time.
  DateTime defaultEntryDate() {
    final now = DateTime.now();
    if (isSelectedToday) return now;
    return DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      now.hour,
      now.minute,
    );
  }

  String get ownerId {
    final uid = Get.find<IAuthService>().currentUser?.uid;
    if (uid != null && uid.isNotEmpty) return uid;
    return 'local_user';
  }

  FinanceMonthSnapshot get snapshot {
    return FinanceMonthSnapshot.from(
      entries: entries,
      categories: categories,
      month: month,
      plan: planFor(month),
      commitments: commitments,
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

  /// Entries for the selected day in day view, or the month in month view.
  List<FinanceEntry> get periodEntries {
    if (!isDayView) return visibleEntries;
    final items = entriesForDate(selectedDay)
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return items;
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

  int _loadGeneration = 0;

  Future<void> load() async {
    final generation = ++_loadGeneration;
    isLoading = true;
    update(['finance']);
    final owner = ownerId;
    if (owner.isEmpty) {
      isLoading = false;
      update(['finance']);
      return;
    }
    final freshCategories = await _repository.fetchCategories(owner);
    final freshEntries = await _repository.fetchEntries(owner);
    final freshPlans = await _repository.fetchMonthPlans(owner);
    if (generation != _loadGeneration || isClosed) return;
    categories = freshCategories;
    entries = freshEntries;
    monthPlans = freshPlans;
    _loadCommitments();
    await _ensureCarriedPlan();
    isLoading = false;
    update(['finance']);
  }

  void _loadCommitments() {
    final raw = _storage?.read<String>(StorageKeys.financeCommitments);
    if (raw == null || raw.isEmpty) {
      commitments = [];
      return;
    }
    try {
      final list = jsonDecode(raw);
      if (list is List) {
        commitments = list
            .whereType<Map>()
            .map(
              (m) => FinanceCommitment.fromMap(
                m['id']?.toString() ?? '',
                Map<String, dynamic>.from(m),
              ),
            )
            .toList();
      }
    } catch (_) {
      commitments = [];
    }
  }

  Future<void> _saveCommitments() async {
    final jsonString = jsonEncode(commitments.map((c) => c.toMap()).toList());
    await _storage?.write(StorageKeys.financeCommitments, jsonString);
  }

  Future<void> addCommitment({
    required String title,
    required double amount,
    required int dueDay,
    String categoryId = '',
    String note = '',
  }) async {
    final now = DateTime.now();
    final item = FinanceCommitment(
      id: '${now.microsecondsSinceEpoch}_${commitments.length}',
      ownerId: ownerId,
      title: title.trim(),
      amount: amount,
      dueDay: dueDay,
      isPaid: false,
      categoryId: categoryId,
      note: note.trim(),
      createdAt: now,
      updatedAt: now,
    );
    commitments = [...commitments, item];
    await _saveCommitments();
    update(['finance']);
  }

  Future<void> toggleCommitmentPaid(FinanceCommitment item) async {
    final updated = item.copyWith(
      isPaid: !item.isPaid,
      updatedAt: DateTime.now(),
    );
    commitments = commitments
        .map((c) => c.id == item.id ? updated : c)
        .toList();
    await _saveCommitments();
    update(['finance']);
  }

  Future<void> deleteCommitment(FinanceCommitment item) async {
    commitments = commitments.where((c) => c.id != item.id).toList();
    await _saveCommitments();
    update(['finance']);
  }

  // ---------------------------------------------------------------------------
  // Daily Tracking Hub & Commitments Board
  // ---------------------------------------------------------------------------
  List<FinanceEntry> entriesForDate(DateTime date) {
    return entries.where((e) {
      return e.occurredAt.year == date.year &&
          e.occurredAt.month == date.month &&
          e.occurredAt.day == date.day;
    }).toList();
  }

  double dailySpendForDate(DateTime date) {
    final dayEntries = entriesForDate(date);
    return dayEntries
        .where((e) => e.isExpense)
        .fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  double dailyIncomeForDate(DateTime date) {
    final dayEntries = entriesForDate(date);
    return dayEntries
        .where((e) => e.isInflow)
        .fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  double get dailySafeLimit {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = (daysInMonth - now.day + 1).clamp(1, 31);
    final plan = planFor(DateTime(now.year, now.month));
    final remainingBudget = plan.spendBudget - snapshot.spend;
    if (remainingBudget <= 0) {
      final safeLiq = snapshot.safeLiquidity;
      return safeLiq > 0 ? (safeLiq / daysLeft) : 0.0;
    }
    return remainingBudget / daysLeft;
  }

  List<FinanceCommitment> commitmentsDueOnDate(DateTime date) {
    return commitments.where((c) => c.dueDay == date.day).toList();
  }

  Map<String, List<FinanceCommitment>> get commitmentsByStatus {
    final todayDay = DateTime.now().day;
    final dueToday = <FinanceCommitment>[];
    final upcoming = <FinanceCommitment>[];
    final paid = <FinanceCommitment>[];

    for (final c in commitments) {
      if (c.isPaid) {
        paid.add(c);
      } else if (c.dueDay == todayDay) {
        dueToday.add(c);
      } else {
        upcoming.add(c);
      }
    }
    return {'dueToday': dueToday, 'upcoming': upcoming, 'paid': paid};
  }

  Future<void> onAccountReady() async {
    await _repository.syncAfterLogin(ownerId);
    await load();
  }

  /// Drops the signed-out account's data from memory.
  void clearAccountData() {
    _loadGeneration++;
    categories = [];
    entries = [];
    monthPlans = [];
    commitments = [];
    selectedCategoryId = null;
    isLoading = true;
    update(['finance']);
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

  /// The current month and the months before it, oldest first.
  List<DateTime> nearbyMonths({int count = 7}) {
    final now = DateTime(DateTime.now().year, DateTime.now().month);
    return [
      for (var offset = count - 1; offset >= 0; offset--)
        DateTime(now.year, now.month - offset),
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
    bool select = true,
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
    if (select) selectedCategoryId = category.id;
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
