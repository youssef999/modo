import '../models/goal_category.dart';
import '../models/goal_model.dart';
import 'firestore_goal_repository.dart';
import 'i_goal_repository.dart';
import 'local_goal_repository.dart';

class CachedGoalRepository implements IGoalRepository {
  CachedGoalRepository({
    required this.local,
    this.remote,
    required this.isCloudEnabled,
  });

  final LocalGoalRepository local;
  final FirestoreGoalRepository? remote;
  final bool Function() isCloudEnabled;

  bool get _useCloud => remote != null && isCloudEnabled();

  @override
  Future<List<GoalCategory>> fetchCategories(String ownerId) async {
    var items = await local.fetchCategories(ownerId);
    if (_useCloud) {
      try {
        items = GoalCategory.withMissingBuiltIns(ownerId, items);
        await remote!.saveAllCategories(items);
        items = await remote!.fetchCategories(ownerId);
        if (items.isEmpty) {
          items = GoalCategory.builtIns(ownerId);
          await remote!.saveAllCategories(items);
        } else {
          items = GoalCategory.withMissingBuiltIns(ownerId, items);
          await remote!.saveAllCategories(items);
        }
        await local.replaceCategories(items);
      } catch (_) {}
      return items;
    }
    return items;
  }

  @override
  Future<GoalCategory> addCategory({
    required String ownerId,
    required String name,
    String iconKey = 'star',
  }) async {
    final category = await local.addCategory(
      ownerId: ownerId,
      name: name,
      iconKey: iconKey,
    );
    await _tryCloud(() => remote!.saveCategory(category));
    return category;
  }

  @override
  Future<void> updateCategory(GoalCategory category) async {
    await local.updateCategory(category);
    await _tryCloud(() => remote!.saveCategory(category));
  }

  @override
  Future<List<GoalModel>> fetch(String ownerId) async {
    final localGoals = await local.fetch(ownerId);
    if (_useCloud) {
      return _fetchFromCloud(ownerId, localGoals);
    }
    if (localGoals.isEmpty) {
      return _hydrateFromAnonymousCloud(ownerId);
    }
    return localGoals;
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
    final goal = await local.create(
      ownerId: ownerId,
      title: title,
      details: details,
      kind: kind,
      startsAt: startsAt,
      dueAt: dueAt,
      category: category,
    );
    await _tryCloud(() => remote!.save(goal));
    return goal;
  }

  @override
  Future<void> update(GoalModel goal) async {
    await local.update(goal);
    await _tryCloud(() => remote!.save(goal));
  }

  @override
  Future<void> delete(String ownerId, String id) async {
    await local.delete(ownerId, id);
    await _tryCloud(() => remote!.delete(ownerId, id));
  }

  @override
  Future<void> syncAfterLogin(String ownerId) async {
    final categories = await local.fetchCategories(ownerId);
    final localGoals = await local.fetch(ownerId);
    if (!_useCloud) return;
    await _tryCloud(() => remote!.saveAllCategories(categories));
    await _tryCloud(() => remote!.saveAll(localGoals));
    try {
      await local.replaceCategories(await remote!.fetchCategories(ownerId));
      await local.replaceAll(await remote!.fetch(ownerId));
    } catch (_) {}
  }

  Future<List<GoalModel>> _fetchFromCloud(
    String ownerId,
    List<GoalModel> localGoals,
  ) async {
    try {
      await remote!.saveAll(localGoals);
      final remoteGoals = await remote!.fetch(ownerId);
      await local.replaceAll(remoteGoals);
      return remoteGoals;
    } catch (_) {
      return localGoals;
    }
  }

  Future<List<GoalModel>> _hydrateFromAnonymousCloud(String ownerId) async {
    final cloud = remote;
    if (cloud == null || ownerId.isEmpty) return const [];
    try {
      final remoteGoals = await cloud.fetch(ownerId);
      if (remoteGoals.isEmpty) return const [];
      await local.replaceAll(remoteGoals);
      return remoteGoals;
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
