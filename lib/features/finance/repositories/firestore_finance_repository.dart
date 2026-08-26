import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_daily_app/core/constants/firestore_paths.dart';

import '../models/finance_category.dart';
import '../models/finance_category_role.dart';
import '../models/finance_entry.dart';
import '../models/finance_month_plan.dart';
import 'i_finance_repository.dart';

class FirestoreFinanceRepository implements IFinanceRepository {
  FirestoreFinanceRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _categories(String ownerId) {
    return _db.collection(FirestorePaths.userFinanceCategories(ownerId));
  }

  CollectionReference<Map<String, dynamic>> _entries(String ownerId) {
    return _db.collection(FirestorePaths.userFinance(ownerId));
  }

  CollectionReference<Map<String, dynamic>> _plans(String ownerId) {
    return _db.collection(FirestorePaths.userFinanceMonthPlans(ownerId));
  }

  @override
  Future<List<FinanceCategory>> fetchCategories(String ownerId) async {
    final snapshot = await _categories(ownerId).get();
    return snapshot.docs.map(_categoryFromDoc).toList();
  }

  @override
  Future<FinanceCategory> addCategory({
    required String ownerId,
    required String name,
    FinanceCategoryRole role = FinanceCategoryRole.spend,
    String iconKey = 'star',
  }) async {
    final now = DateTime.now();
    final ref = _categories(ownerId).doc();
    final category = FinanceCategory(
      id: ref.id,
      ownerId: ownerId,
      name: name.trim(),
      builtInKey: '',
      iconKey: iconKey.trim().isEmpty ? 'star' : iconKey.trim(),
      role: role,
      createdAt: now,
      updatedAt: now,
    );
    await saveCategory(category);
    return category;
  }

  @override
  Future<List<FinanceEntry>> fetchEntries(String ownerId) async {
    final snapshot = await _entries(ownerId).get();
    final items = snapshot.docs.map(_entryFromDoc).toList();
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
    final ref = _entries(ownerId).doc();
    final entry = FinanceEntry(
      id: ref.id,
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
    await saveEntry(entry);
    return entry;
  }

  @override
  Future<void> deleteEntry(String ownerId, String id) {
    return _entries(ownerId).doc(id).delete();
  }

  @override
  Future<List<FinanceMonthPlan>> fetchMonthPlans(String ownerId) async {
    final snapshot = await _plans(ownerId).get();
    return snapshot.docs.map(_planFromDoc).toList();
  }

  @override
  Future<FinanceMonthPlan> saveMonthPlan(FinanceMonthPlan plan) async {
    await _plans(plan.ownerId).doc(plan.id).set(_planToFirestore(plan));
    return plan;
  }

  @override
  Future<void> syncAfterLogin(String ownerId) async {}

  Future<void> saveCategory(FinanceCategory category) {
    return _categories(
      category.ownerId,
    ).doc(category.id).set(_categoryToFirestore(category));
  }

  Future<void> saveEntry(FinanceEntry entry) {
    return _entries(entry.ownerId).doc(entry.id).set(_entryToFirestore(entry));
  }

  Future<void> saveAllCategories(List<FinanceCategory> items) {
    return _commit(items, (item) {
      return _categories(item.ownerId).doc(item.id);
    }, _categoryToFirestore);
  }

  Future<void> saveAllEntries(List<FinanceEntry> items) {
    return _commit(items, (item) {
      return _entries(item.ownerId).doc(item.id);
    }, _entryToFirestore);
  }

  Future<void> saveAllMonthPlans(List<FinanceMonthPlan> items) {
    return _commit(items, (item) {
      return _plans(item.ownerId).doc(item.id);
    }, _planToFirestore);
  }

  Future<void> _commit<T>(
    List<T> items,
    DocumentReference<Map<String, dynamic>> Function(T item) ref,
    Map<String, dynamic> Function(T item) toData,
  ) async {
    if (items.isEmpty) return;
    var batch = _db.batch();
    var count = 0;
    for (final item in items) {
      batch.set(ref(item), toData(item));
      count++;
      if (count == 450) {
        await batch.commit();
        batch = _db.batch();
        count = 0;
      }
    }
    if (count > 0) await batch.commit();
  }

  Map<String, dynamic> _categoryToFirestore(FinanceCategory category) {
    return {
      'ownerId': category.ownerId,
      'name': category.name,
      'builtInKey': category.builtInKey,
      'iconKey': category.iconKey,
      'role': category.role.name,
      'createdAt': Timestamp.fromDate(category.createdAt),
      'updatedAt': Timestamp.fromDate(category.updatedAt),
    };
  }

  Map<String, dynamic> _entryToFirestore(FinanceEntry entry) {
    return {
      'ownerId': entry.ownerId,
      'kind': entry.kind.name,
      'title': entry.title,
      'amount': entry.amount,
      'categoryId': entry.categoryId,
      'occurredAt': Timestamp.fromDate(entry.occurredAt),
      'note': entry.note,
      'createdAt': Timestamp.fromDate(entry.createdAt),
      'updatedAt': Timestamp.fromDate(entry.updatedAt),
    };
  }

  Map<String, dynamic> _planToFirestore(FinanceMonthPlan plan) {
    return {
      'ownerId': plan.ownerId,
      'yearMonth': plan.yearMonth,
      'expectedSalary': plan.expectedSalary,
      'spendBudget': plan.spendBudget,
      'createdAt': Timestamp.fromDate(plan.createdAt),
      'updatedAt': Timestamp.fromDate(plan.updatedAt),
    };
  }

  FinanceCategory _categoryFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return FinanceCategory(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      builtInKey: data['builtInKey'] as String? ?? '',
      iconKey: data['iconKey'] as String? ?? 'custom',
      role: FinanceCategoryRoleX.fromStorage(data['role'] as String?),
      createdAt: _date(data['createdAt']),
      updatedAt: _date(data['updatedAt']),
    );
  }

  FinanceEntry _entryFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdAt = _date(data['createdAt']);
    return FinanceEntry(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      kind: FinanceEntry.kindFrom(data['kind'] as String?),
      title: data['title'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      categoryId: data['categoryId'] as String? ?? '',
      occurredAt: data['occurredAt'] == null
          ? createdAt
          : _date(data['occurredAt']),
      note: data['note'] as String? ?? '',
      createdAt: createdAt,
      updatedAt: _date(data['updatedAt']),
    );
  }

  FinanceMonthPlan _planFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return FinanceMonthPlan(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      yearMonth: data['yearMonth'] as String? ?? doc.id,
      expectedSalary: (data['expectedSalary'] as num?)?.toDouble() ?? 0,
      spendBudget: (data['spendBudget'] as num?)?.toDouble() ?? 0,
      createdAt: _date(data['createdAt']),
      updatedAt: _date(data['updatedAt']),
    );
  }

  DateTime _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
