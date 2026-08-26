import '../models/goal_category.dart';
import '../models/goal_model.dart';

abstract class IGoalRepository {
  Future<List<GoalCategory>> fetchCategories(String ownerId);

  Future<GoalCategory> addCategory({
    required String ownerId,
    required String name,
    String iconKey = 'star',
  });

  Future<void> updateCategory(GoalCategory category);

  Future<List<GoalModel>> fetch(String ownerId);

  Future<GoalModel> create({
    required String ownerId,
    required String title,
    required String details,
    required GoalKind kind,
    required DateTime startsAt,
    required DateTime dueAt,
    required String category,
  });

  Future<void> update(GoalModel goal);

  Future<void> delete(String ownerId, String id);

  Future<void> syncAfterLogin(String ownerId);
}
