import 'dart:convert';
import 'dart:math';

import 'package:life_daily_app/core/constants/storage_keys.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';

import '../models/finance_category.dart';
import '../models/finance_category_role.dart';
import '../models/finance_entry.dart';
import '../models/finance_month_plan.dart';
import 'i_finance_repository.dart';

class LocalFinanceRepository implements IFinanceRepository {
  LocalFinanceRepository(this._storage);

  final IStorage _storage;
  final _random = Random();

  @override
  Future<List<FinanceCategory>> fetchCategories(String ownerId) async {
    var items = _readCategories();
    if (ownerId.isNotEmpty && items.any((item) => item.ownerId != ownerId)) {
      items = [
        for (final item in items)
          item.ownerId == ownerId ? item : item.copyWith(ownerId: ownerId),
      ];
      await replaceCategories(items);
    }
    if (items.isEmpty && ownerId.isNotEmpty) {
      items = FinanceCategory.builtIns(ownerId);
      await replaceCategories(items);
    } else if (ownerId.isNotEmpty) {
      final merged = FinanceCategory.withMissingBuiltIns(ownerId, items);
      if (merged.length != items.length) {
        items = merged;
        await replaceCategories(items);
      }
    }
    return items;
  }

  @override
  Future<FinanceCategory> addCategory({
    required String ownerId,
    required String name,
    FinanceCategoryRole role = FinanceCategoryRole.spend,
    String iconKey = 'star',
  }) async {
    final now = DateTime.now();
    final category = FinanceCategory(
      id: '${now.microsecondsSinceEpoch}${_random.nextInt(999)}',
      ownerId: ownerId,
      name: name.trim(),
      builtInKey: '',
      iconKey: iconKey.trim().isEmpty ? 'star' : iconKey.trim(),
      role: role,
      createdAt: now,
      updatedAt: now,
    );
    final items = _readCategories()..add(category);
    await replaceCategories(items);
    return category;
  }

  @override
  Future<List<FinanceEntry>> fetchEntries(String ownerId) async {
    var items = _readEntries();
    if (ownerId.isNotEmpty && items.any((item) => item.ownerId != ownerId)) {
      items = [
        for (final item in items)
          item.ownerId == ownerId ? item : item.copyWith(ownerId: ownerId),
      ];
      await replaceEntries(items);
    }
    items.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return items;
  }

  @override
  Future<FinanceEntry> addEntry({
    required String ownerId,
    required FinanceKind kind,
    required String title,
    required double amount,
    required String categoryId,
    required DateTime occurredAt,
    required String note,
  }) async {
    final now = DateTime.now();
    final entry = FinanceEntry(
      id: '${now.microsecondsSinceEpoch}${_random.nextInt(999)}',
      ownerId: ownerId,
      kind: kind,
      title: title.trim(),
      amount: amount,
      categoryId: categoryId,
      occurredAt: DateTime(occurredAt.year, occurredAt.month, occurredAt.day),
      note: note.trim(),
      createdAt: now,
      updatedAt: now,
    );
    final items = _readEntries()..add(entry);
    await replaceEntries(items);
    return entry;
  }

  @override
  Future<void> deleteEntry(String ownerId, String id) async {
    final items = _readEntries()
      ..removeWhere((item) => item.id == id && item.ownerId == ownerId);
    await replaceEntries(items);
  }

  @override
  Future<List<FinanceMonthPlan>> fetchMonthPlans(String ownerId) async {
    var items = _readPlans();
    if (ownerId.isNotEmpty && items.any((item) => item.ownerId != ownerId)) {
      items = [
        for (final item in items)
          item.ownerId == ownerId ? item : item.copyWith(ownerId: ownerId),
      ];
      await replaceMonthPlans(items);
    }
    return items;
  }

  @override
  Future<FinanceMonthPlan> saveMonthPlan(FinanceMonthPlan plan) async {
    final items = _readPlans();
    final index = items.indexWhere((item) => item.id == plan.id);
    if (index == -1) {
      items.add(plan);
    } else {
      items[index] = plan;
    }
    await replaceMonthPlans(items);
    return plan;
  }

  @override
  Future<void> syncAfterLogin(String ownerId) async {
    await fetchCategories(ownerId);
    await fetchEntries(ownerId);
    await fetchMonthPlans(ownerId);
  }

  Future<void> saveCategory(FinanceCategory category) async {
    final items = _readCategories();
    final index = items.indexWhere((item) => item.id == category.id);
    if (index == -1) {
      items.add(category);
    } else {
      items[index] = category;
    }
    await replaceCategories(items);
  }

  Future<void> saveEntry(FinanceEntry entry) async {
    final items = _readEntries();
    final index = items.indexWhere((item) => item.id == entry.id);
    if (index == -1) {
      items.add(entry);
    } else {
      items[index] = entry;
    }
    await replaceEntries(items);
  }

  Future<void> replaceCategories(List<FinanceCategory> items) {
    final payload = items
        .map((item) => {'id': item.id, ...item.toMap()})
        .toList();
    return _storage.write(StorageKeys.financeCategories, jsonEncode(payload));
  }

  Future<void> replaceEntries(List<FinanceEntry> items) {
    final payload = items
        .map((item) => {'id': item.id, ...item.toMap()})
        .toList();
    return _storage.write(StorageKeys.financeEntries, jsonEncode(payload));
  }

  Future<void> replaceMonthPlans(List<FinanceMonthPlan> items) {
    final payload = items
        .map((item) => {'id': item.id, ...item.toMap()})
        .toList();
    return _storage.write(StorageKeys.financeMonthPlans, jsonEncode(payload));
  }

  List<FinanceCategory> _readCategories() {
    return _decode(StorageKeys.financeCategories, FinanceCategory.fromMap);
  }

  List<FinanceEntry> _readEntries() {
    return _decode(StorageKeys.financeEntries, FinanceEntry.fromMap);
  }

  List<FinanceMonthPlan> _readPlans() {
    return _decode(StorageKeys.financeMonthPlans, FinanceMonthPlan.fromMap);
  }

  List<T> _decode<T>(
    String key,
    T Function(String id, Map<String, dynamic> data) parse,
  ) {
    final raw = _storage.read<String>(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (item) => parse(
              item['id'] as String,
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }
}
