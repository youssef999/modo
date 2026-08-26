import 'dart:convert';
import 'dart:math';

import 'package:life_daily_app/core/constants/storage_keys.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';

import '../models/goal_category.dart';
import '../models/goal_model.dart';
import 'i_goal_repository.dart';

class LocalGoalRepository implements IGoalRepository {
  LocalGoalRepository(this._storage);

  final IStorage _storage;
  final _random = Random();

  @override
  Future<List<GoalCategory>> fetchCategories(String ownerId) async {
    var items = _readCategories();
    if (ownerId.isNotEmpty && items.any((item) => item.ownerId != ownerId)) {
      items = [
        for (final item in items)
          item.ownerId == ownerId ? item : item.copyWith(ownerId: ownerId),
      ];
      await replaceCategories(items);
    }
    if (items.isEmpty && ownerId.isNotEmpty) {
      items = GoalCategory.builtIns(ownerId);
      await replaceCategories(items);
    } else if (ownerId.isNotEmpty) {
      final merged = GoalCategory.withMissingBuiltIns(ownerId, items);
      if (merged.length != items.length) {
        items = merged;
        await replaceCategories(items);
      }
    }
    return items;
  }

  @override
  Future<GoalCategory> addCategory({
    required String ownerId,
    required String name,
    String iconKey = 'star',
  }) async {
    final now = DateTime.now();
    final category = GoalCategory(
      id: '${now.microsecondsSinceEpoch}${_random.nextInt(999)}',
      ownerId: ownerId,
      name: name.trim(),
      builtInKey: '',
      iconKey: iconKey.trim().isEmpty ? 'star' : iconKey.trim(),
      createdAt: now,
      updatedAt: now,
    );
    final items = _readCategories()..add(category);
    await replaceCategories(items);
    return category;
  }

  @override
  Future<void> updateCategory(GoalCategory category) {
    return saveCategory(category.copyWith(updatedAt: DateTime.now()));
  }

  @override
  Future<List<GoalModel>> fetch(String ownerId) async {
    var goals = _read();
    if (ownerId.isNotEmpty && goals.any((goal) => goal.ownerId != ownerId)) {
      goals = [
        for (final goal in goals)
          goal.ownerId == ownerId ? goal : goal.copyWith(ownerId: ownerId),
      ];
      await _write(goals);
    }
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
    final goal = GoalModel(
      id:
          now.microsecondsSinceEpoch.toString() +
          _random.nextInt(999).toString(),
      ownerId: ownerId,
      title: title,
      details: details,
      kind: kind,
      startsAt: GoalModel.dateOnly(startsAt),
      dueAt: GoalModel.dateOnly(dueAt),
      category: category,
      status: GoalStatus.active,
      checkIns: const [],
      createdAt: now,
      updatedAt: now,
    );
    await save(goal);
    return goal;
  }

  @override
  Future<void> update(GoalModel goal) {
    return save(goal.copyWith(updatedAt: DateTime.now()));
  }

  @override
  Future<void> delete(String ownerId, String id) async {
    final goals = _read()
      ..removeWhere((goal) => goal.id == id && goal.ownerId == ownerId);
    await _write(goals);
  }

  @override
  Future<void> syncAfterLogin(String ownerId) async {
    await fetchCategories(ownerId);
    await fetch(ownerId);
  }

  Future<void> saveCategory(GoalCategory category) async {
    final items = _readCategories();
    final index = items.indexWhere((item) => item.id == category.id);
    if (index == -1) {
      items.add(category);
    } else {
      items[index] = category;
    }
    await replaceCategories(items);
  }

  Future<void> save(GoalModel goal) async {
    final goals = _read();
    final index = goals.indexWhere((item) => item.id == goal.id);
    if (index == -1) {
      goals.add(goal);
    } else {
      goals[index] = goal;
    }
    await _write(goals);
  }

  Future<void> replaceAll(List<GoalModel> goals) => _write(goals);

  Future<void> replaceCategories(List<GoalCategory> items) {
    final payload = items
        .map((item) => {'id': item.id, ...item.toMap()})
        .toList();
    return _storage.write(StorageKeys.goalCategories, jsonEncode(payload));
  }

  List<GoalCategory> _readCategories() {
    final raw = _storage.read<String>(StorageKeys.goalCategories);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (item) => GoalCategory.fromMap(
              item['id'] as String,
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<GoalModel> _read() {
    final raw = _storage.read<String>(StorageKeys.goalsCache);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (item) => GoalModel.fromMap(
              item['id'] as String,
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _write(List<GoalModel> goals) {
    final payload = goals
        .map((goal) => {'id': goal.id, ...goal.toMap()})
        .toList();
    return _storage.write(StorageKeys.goalsCache, jsonEncode(payload));
  }
}
