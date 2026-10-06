import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_daily_app/core/constants/firestore_paths.dart';

import '../models/goal_category.dart';
import '../models/goal_model.dart';
import 'i_goal_repository.dart';

class FirestoreGoalRepository implements IGoalRepository {
  FirestoreGoalRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String ownerId) {
    return _db.collection(FirestorePaths.userGoals(ownerId));
  }

  CollectionReference<Map<String, dynamic>> get _topGoalsCol {
    return _db.collection(FirestorePaths.goals);
  }

  CollectionReference<Map<String, dynamic>> _categories(String ownerId) {
    return _db.collection(FirestorePaths.userGoalCategories(ownerId));
  }

  @override
  Future<List<GoalCategory>> fetchCategories(String ownerId) async {
    final snapshot = await _categories(ownerId).get();
    return snapshot.docs.map(_categoryFromDoc).toList();
  }

  @override
  Future<GoalCategory> addCategory({
    required String ownerId,
    required String name,
    String iconKey = 'star',
  }) async {
    final now = DateTime.now();
    final ref = _categories(ownerId).doc();
    final category = GoalCategory(
      id: ref.id,
      ownerId: ownerId,
      name: name.trim(),
      builtInKey: '',
      iconKey: iconKey.trim().isEmpty ? 'star' : iconKey.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await saveCategory(category);
    return category;
  }

  @override
  Future<void> updateCategory(GoalCategory category) {
    return saveCategory(category.copyWith(updatedAt: DateTime.now()));
  }

  @override
  Future<List<GoalModel>> fetch(String ownerId) async {
    final Map<String, GoalModel> goalMap = {};

    try {
      // 1. Fetch goals where ownerId is in memberIds (collaborator/partner or owner)
      final memberSnapshot = await _topGoalsCol
          .where('memberIds', arrayContains: ownerId)
          .get();
      for (final doc in memberSnapshot.docs) {
        goalMap[doc.id] = _fromDoc(doc);
      }

      // 2. Fetch goals directly owned by user in top-level goals
      final ownerSnapshot = await _topGoalsCol
          .where('ownerId', isEqualTo: ownerId)
          .get();
      for (final doc in ownerSnapshot.docs) {
        goalMap[doc.id] = _fromDoc(doc);
      }
    } catch (_) {}

    // 3. Fallback/compatibility: check user's subcollection
    try {
      final userSnapshot = await _col(ownerId).get();
      for (final doc in userSnapshot.docs) {
        goalMap.putIfAbsent(doc.id, () => _fromDoc(doc));
      }
    } catch (_) {}

    final goals = goalMap.values.toList();
    goals.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return goals;
  }

  @override
  Future<GoalModel> create({
    required String ownerId,
    required String title,
    required String details,
    required GoalKind kind,
    required DateTime startsAt,
    required DateTime dueAt,
    required String category,
  }) async {
    final now = DateTime.now();
    final ref = _topGoalsCol.doc();
    final goal = GoalModel(
      id: ref.id,
      ownerId: ownerId,
      title: title,
      details: details,
      kind: kind,
      startsAt: GoalModel.dateOnly(startsAt),
      dueAt: GoalModel.dateOnly(dueAt),
      category: category,
      status: GoalStatus.notStarted,
      checkIns: const [],
      createdAt: now,
      updatedAt: now,
      memberIds: [ownerId],
      members: const [],
    );
    await save(goal);
    return goal;
  }

  @override
  Future<void> update(GoalModel goal) {
    return save(goal);
  }

  Future<void> save(GoalModel goal) async {
    final data = _toFirestore(goal);
    await Future.wait([
      _topGoalsCol.doc(goal.id).set(data),
      _col(goal.ownerId).doc(goal.id).set(data),
    ]);
  }

  Future<void> saveCategory(GoalCategory category) {
    return _categories(
      category.ownerId,
    ).doc(category.id).set(_categoryToFirestore(category));
  }

  Future<void> saveAllCategories(List<GoalCategory> items) async {
    if (items.isEmpty) return;
    var batch = _db.batch();
    var count = 0;
    for (final item in items) {
      batch.set(
        _categories(item.ownerId).doc(item.id),
        _categoryToFirestore(item),
      );
      count++;
      if (count == 450) {
        await batch.commit();
        batch = _db.batch();
        count = 0;
      }
    }
    if (count > 0) await batch.commit();
  }

  Future<void> saveAll(List<GoalModel> goals) async {
    if (goals.isEmpty) return;
    for (final goal in goals) {
      await save(goal);
    }
  }

  @override
  Future<void> delete(String ownerId, String id) async {
    await Future.wait([
      _topGoalsCol.doc(id).delete(),
      _col(ownerId).doc(id).delete(),
    ]);
  }

  @override
  Future<void> syncAfterLogin(String ownerId) async {}

  Map<String, dynamic> _toFirestore(GoalModel goal) {
    final memberIds = goal.memberIds.isNotEmpty
        ? goal.memberIds
        : [goal.ownerId];

    return {
      'ownerId': goal.ownerId,
      'title': goal.title,
      'details': goal.details,
      'kind': goal.kind.name,
      'startsAt': Timestamp.fromDate(goal.startsAt),
      'dueAt': Timestamp.fromDate(goal.dueAt),
      'category': goal.category,
      'status': goal.status.name,
      'priority': goal.priority.name,
      'checkIns': goal.checkIns,
      'boardOrder': goal.boardOrder,
      'tasks': goal.tasks.map((t) => t.toMap()).toList(),
      'trackers': goal.trackers.map((t) => t.toMap()).toList(),
      'memberIds': memberIds,
      'members': goal.members.map((m) => m.toMap()).toList(),
      if (goal.isInbox) 'isInbox': true,
      'createdAt': Timestamp.fromDate(goal.createdAt),
      'updatedAt': Timestamp.fromDate(goal.updatedAt),
    };
  }

  GoalModel _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return GoalModel.fromMap(doc.id, data);
  }

  Map<String, dynamic> _categoryToFirestore(GoalCategory category) {
    return {
      'ownerId': category.ownerId,
      'name': category.name,
      'builtInKey': category.builtInKey,
      'iconKey': category.iconKey,
      'createdAt': Timestamp.fromDate(category.createdAt),
      'updatedAt': Timestamp.fromDate(category.updatedAt),
    };
  }

  GoalCategory _categoryFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return GoalCategory(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      builtInKey: data['builtInKey'] as String? ?? '',
      iconKey: data['iconKey'] as String? ?? 'custom',
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
