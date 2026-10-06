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
    if (_useCloud) {
      try {
        var items = await _retryRead(() => remote!.fetchCategories(ownerId));
        if (items.isEmpty) {
          items = GoalCategory.builtIns(ownerId);
          await remote!.saveAllCategories(items);
        } else {
          items = GoalCategory.withMissingBuiltIns(ownerId, items);
          await remote!.saveAllCategories(items);
        }
        await local.replaceCategories(items);
        return items;
      } catch (_) {}
    }
    return local.fetchCategories(ownerId);
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
    if (_useCloud) {
      try {
        final remoteGoals = await _retryRead(() => remote!.fetch(ownerId));
        await local.replaceAll(remoteGoals);
        return remoteGoals;
      } catch (_) {
        // Fallback to local cache if offline
        return local.fetch(ownerId);
      }
    }
    return local.fetch(ownerId);
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
    if (!_useCloud) return;
    try {
      final remoteCategories = await remote!.fetchCategories(ownerId);
      if (remoteCategories.isNotEmpty) {
        await local.replaceCategories(remoteCategories);
      }
      final remoteGoals = await remote!.fetch(ownerId);
      if (remoteGoals.isNotEmpty) {
        await local.replaceAll(remoteGoals);
      }
    } catch (_) {}
  }

  /// Right after sign-in Firestore can still hold the previous token for a
  /// moment, so one failed read is retried before falling back to the cache.
  Future<T> _retryRead<T>(Future<T> Function() read) async {
    try {
      return await read();
    } catch (_) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      return read();
    }
  }

  Future<void> _tryCloud(Future<void> Function() action) async {
    if (!_useCloud) return;
    try {
      await action();
    } catch (_) {}
  }
}
