import '../models/finance_category.dart';
import '../models/finance_category_role.dart';
import '../models/finance_entry.dart';
import '../models/finance_month_plan.dart';
import 'firestore_finance_repository.dart';
import 'i_finance_repository.dart';
import 'local_finance_repository.dart';

class CachedFinanceRepository implements IFinanceRepository {
  CachedFinanceRepository({
    required this.local,
    this.remote,
    required this.isCloudEnabled,
  });

  final LocalFinanceRepository local;
  final FirestoreFinanceRepository? remote;
  final bool Function() isCloudEnabled;

  bool get _useCloud => remote != null && isCloudEnabled();

  @override
  Future<List<FinanceCategory>> fetchCategories(String ownerId) async {
    var items = await local.fetchCategories(ownerId);
    if (_useCloud) {
      try {
        items = FinanceCategory.withMissingBuiltIns(ownerId, items);
        await remote!.saveAllCategories(items);
        items = await remote!.fetchCategories(ownerId);
        if (items.isEmpty) {
          items = FinanceCategory.builtIns(ownerId);
          await remote!.saveAllCategories(items);
        } else {
          items = FinanceCategory.withMissingBuiltIns(ownerId, items);
          await remote!.saveAllCategories(items);
        }
        await local.replaceCategories(items);
      } catch (_) {}
      return items;
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
    final category = await local.addCategory(
      ownerId: ownerId,
      name: name,
      role: role,
      iconKey: iconKey,
    );
    await _tryCloud(() => remote!.saveCategory(category));
    return category;
  }

  @override
  Future<List<FinanceEntry>> fetchEntries(String ownerId) async {
    var items = await local.fetchEntries(ownerId);
    if (_useCloud) {
      try {
        await remote!.saveAllEntries(items);
        items = await remote!.fetchEntries(ownerId);
        await local.replaceEntries(items);
      } catch (_) {}
      return items;
    }
    if (items.isEmpty) {
      items = await _hydrateEntries(ownerId);
    }
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
    final entry = await local.addEntry(
      ownerId: ownerId,
      kind: kind,
      title: title,
      amount: amount,
      categoryId: categoryId,
      occurredAt: occurredAt,
      note: note,
    );
    await _tryCloud(() => remote!.saveEntry(entry));
    return entry;
  }

  @override
  Future<void> deleteEntry(String ownerId, String id) async {
    await local.deleteEntry(ownerId, id);
    await _tryCloud(() => remote!.deleteEntry(ownerId, id));
  }

  @override
  Future<List<FinanceMonthPlan>> fetchMonthPlans(String ownerId) async {
    var items = await local.fetchMonthPlans(ownerId);
    if (_useCloud) {
      try {
        await remote!.saveAllMonthPlans(items);
        items = await remote!.fetchMonthPlans(ownerId);
        await local.replaceMonthPlans(items);
      } catch (_) {}
      return items;
    }
    return items;
  }

  @override
  Future<FinanceMonthPlan> saveMonthPlan(FinanceMonthPlan plan) async {
    final saved = await local.saveMonthPlan(plan);
    await _tryCloud(() => remote!.saveMonthPlan(saved));
    return saved;
  }

  @override
  Future<void> syncAfterLogin(String ownerId) async {
    final categories = await local.fetchCategories(ownerId);
    final entries = await local.fetchEntries(ownerId);
    final plans = await local.fetchMonthPlans(ownerId);
    if (!_useCloud) return;
    await _tryCloud(() => remote!.saveAllCategories(categories));
    await _tryCloud(() => remote!.saveAllEntries(entries));
    await _tryCloud(() => remote!.saveAllMonthPlans(plans));
    try {
      await local.replaceCategories(await remote!.fetchCategories(ownerId));
      await local.replaceEntries(await remote!.fetchEntries(ownerId));
      await local.replaceMonthPlans(await remote!.fetchMonthPlans(ownerId));
    } catch (_) {}
  }

  Future<List<FinanceEntry>> _hydrateEntries(String ownerId) async {
    final cloud = remote;
    if (cloud == null || ownerId.isEmpty) return const [];
    try {
      final remoteItems = await cloud.fetchEntries(ownerId);
      if (remoteItems.isEmpty) return const [];
      await local.replaceEntries(remoteItems);
      return remoteItems;
    } catch (_) {
      return const [];
    }
  }

  Future<void> _tryCloud(Future<void> Function() action) async {
    if (!_useCloud) return;
    try {
      await action();
    } catch (_) {}
  }
}
