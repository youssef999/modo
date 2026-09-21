import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/models/app_priority.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';
import 'package:life_daily_app/features/auth/models/app_user.dart';
import 'package:life_daily_app/features/auth/services/i_auth_service.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/models/goal_category.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';
import 'package:life_daily_app/features/goals/models/goal_task.dart';
import 'package:life_daily_app/features/goals/repositories/i_goal_repository.dart';

class _FakeAuthService implements IAuthService {
  @override
  AppUser? get currentUser => const AppUser(uid: 'test_user', isAnonymous: false, email: 'test@example.com');
  @override
  Stream<AppUser?> get authStateChanges => Stream.value(currentUser);
  @override
  Future<AppUser> ensureAnonymousSession() async => currentUser!;
  @override
  Future<AppUser> continueWithGoogle() async => currentUser!;
  @override
  Future<AppUser> continueWithApple() async => currentUser!;
  @override
  Future<AppUser> signInWithEmail(String email, String password) async => currentUser!;
  @override
  Future<AppUser> registerWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async => currentUser!;
  @override
  Future<void> sendPasswordReset(String email) async {}
  @override
  Future<void> signOut() async {}
}

class _FakeStorage implements IStorage {
  final Map<String, dynamic> _data = {};
  @override
  T? read<T>(String key) => _data[key] as T?;
  @override
  Future<void> write(String key, dynamic value) async => _data[key] = value;
  @override
  Future<void> remove(String key) async => _data.remove(key);
}

class _FakeGoalRepository implements IGoalRepository {
  List<GoalModel> goals = [];
  List<GoalCategory> categories = [];

  @override
  Future<List<GoalModel>> fetch(String ownerId) async => goals;
  @override
  Future<List<GoalCategory>> fetchCategories(String ownerId) async => categories;
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
    final newGoal = GoalModel(
      id: 'g_${DateTime.now().millisecondsSinceEpoch}',
      ownerId: ownerId,
      title: title,
      details: details,
      kind: kind,
      startsAt: startsAt,
      dueAt: dueAt,
      category: category,
      status: GoalStatus.notStarted,
      checkIns: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    goals.add(newGoal);
    return newGoal;
  }
  @override
  Future<void> update(GoalModel goal) async {
    final idx = goals.indexWhere((g) => g.id == goal.id);
    if (idx != -1) goals[idx] = goal;
  }
  @override
  Future<void> delete(String ownerId, String id) async {
    goals.removeWhere((g) => g.id == id);
  }
  @override
  Future<GoalCategory> addCategory({
    required String ownerId,
    required String name,
    String iconKey = 'star',
  }) async {
    final cat = GoalCategory(
      id: 'c_$name',
      ownerId: ownerId,
      name: name,
      builtInKey: '',
      iconKey: iconKey,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    categories.add(cat);
    return cat;
  }
  @override
  Future<void> updateCategory(GoalCategory category) async {}
  @override
  Future<void> syncAfterLogin(String ownerId) async {}
}

void main() {
  group('Notion-Style Priority & Connected Tasks System Tests', () {
    test('AppPriority attributes and parsing', () {
      expect(AppPriority.urgent.weight, 4);
      expect(AppPriority.high.weight, 3);
      expect(AppPriority.medium.weight, 2);
      expect(AppPriority.low.weight, 1);
      expect(AppPriority.none.weight, 0);

      expect(AppPriority.urgent.isUrgent, isTrue);
      expect(AppPriority.high.isHigh, isTrue);

      expect(AppPriority.fromName('urgent'), AppPriority.urgent);
      expect(AppPriority.fromName('high'), AppPriority.high);
      expect(AppPriority.fromName('medium'), AppPriority.medium);
      expect(AppPriority.fromName('low'), AppPriority.low);
      expect(AppPriority.fromName('none'), AppPriority.none);
      expect(AppPriority.fromName(null), AppPriority.medium);
      expect(AppPriority.fromName('unknown'), AppPriority.medium);
    });

    test('GoalModel and GoalTask Priority serialization and deserialization', () {
      final now = DateTime(2026, 9, 20);
      const task = GoalTask(
        id: 't_notion_1',
        title: 'Design Notion schema',
        status: GoalTaskStatus.todo,
        priority: AppPriority.urgent,
        goalId: 'goal_project_alpha',
      );

      final taskMap = task.toMap();
      expect(taskMap['priority'], 'urgent');
      expect(taskMap['goalId'], 'goal_project_alpha');

      final deserializedTask = GoalTask.fromMap(taskMap);
      expect(deserializedTask.id, 't_notion_1');
      expect(deserializedTask.priority, AppPriority.urgent);
      expect(deserializedTask.goalId, 'goal_project_alpha');

      final goal = GoalModel(
        id: 'goal_project_alpha',
        ownerId: 'user1',
        title: 'Launch The Hatch MVP',
        details: 'Notion-like project management',
        kind: GoalKind.once,
        startsAt: now,
        dueAt: now,
        category: 'work',
        status: GoalStatus.inProgress,
        priority: AppPriority.high,
        checkIns: const [],
        createdAt: now,
        updatedAt: now,
        tasks: [task],
      );

      final goalMap = goal.toMap();
      expect(goalMap['priority'], 'high');

      final deserializedGoal = GoalModel.fromMap('goal_project_alpha', goalMap);
      expect(deserializedGoal.priority, AppPriority.high);
      expect(deserializedGoal.tasks.length, 1);
      expect(deserializedGoal.tasks.first.priority, AppPriority.urgent);
      expect(deserializedGoal.tasks.first.goalId, 'goal_project_alpha');
    });

    test('GoalModel backward compatibility defaults priority to medium and auto-links goalId', () {
      final now = DateTime(2026, 9, 20);
      final legacyMap = {
        'id': 'g_legacy',
        'ownerId': 'user1',
        'title': 'Legacy Goal without priority',
        'details': '',
        'kind': 'once',
        'startsAt': now.toIso8601String(),
        'dueAt': now.toIso8601String(),
        'category': 'course',
        'status': 'inProgress',
        'checkIns': <String>[],
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'tasks': [
          {
            'id': 't_legacy_1',
            'title': 'Legacy Task without priority or goalId',
            'status': 'todo',
            'order': 0,
          },
        ],
      };

      final parsed = GoalModel.fromMap('g_legacy', legacyMap);
      expect(parsed.priority, AppPriority.medium);
      expect(parsed.tasks.first.priority, AppPriority.medium);
      // Connected tasks automatically inherit parent goalId
      expect(parsed.tasks.first.goalId, 'g_legacy');
    });

    test('GoalsController Priority & Reassigning Task between Goals', () async {
      Get.reset();
      Get.put<IAuthService>(_FakeAuthService());
      final repo = _FakeGoalRepository();
      final storage = _FakeStorage();
      final controller = GoalsController(repo, storage);

      final now = DateTime(2026, 9, 20);
      final goal1 = GoalModel(
        id: 'g_1',
        ownerId: 'test_user',
        title: 'Project Alpha',
        details: '',
        kind: GoalKind.once,
        startsAt: now,
        dueAt: now,
        category: 'cat1',
        status: GoalStatus.notStarted,
        priority: AppPriority.medium,
        checkIns: const [],
        createdAt: now,
        updatedAt: now,
      );

      final goal2 = GoalModel(
        id: 'g_2',
        ownerId: 'test_user',
        title: 'Project Beta',
        details: '',
        kind: GoalKind.once,
        startsAt: now,
        dueAt: now,
        category: 'cat1',
        status: GoalStatus.notStarted,
        priority: AppPriority.low,
        checkIns: const [],
        createdAt: now,
        updatedAt: now,
      );

      repo.goals = [goal1, goal2];
      await controller.load();

      // 1. Change Goal Priority
      await controller.changeGoalPriority(goal1, AppPriority.urgent);
      expect(controller.goalById('g_1')?.priority, AppPriority.urgent);

      // 2. Add Task with Priority
      await controller.addTask(
        controller.goalById('g_1')!,
        'Implement Stripe Integration',
        priority: AppPriority.urgent,
      );

      final updatedG1 = controller.goalById('g_1')!;
      expect(updatedG1.tasks.length, 1);
      final task = updatedG1.tasks.first;
      expect(task.title, 'Implement Stripe Integration');
      expect(task.priority, AppPriority.urgent);
      expect(task.goalId, 'g_1');

      // 3. Change Task Priority
      await controller.changeTaskPriority(updatedG1, task.id, AppPriority.high);
      expect(controller.goalById('g_1')?.tasks.first.priority, AppPriority.high);

      // 4. Reassign Task to another Goal (Goal Beta)
      await controller.reassignTaskToGoal(
        fromGoalId: 'g_1',
        toGoalId: 'g_2',
        taskId: task.id,
      );

      final g1AfterMove = controller.goalById('g_1')!;
      final g2AfterMove = controller.goalById('g_2')!;

      expect(g1AfterMove.tasks.isEmpty, isTrue);
      expect(g2AfterMove.tasks.length, 1);
      expect(g2AfterMove.tasks.first.title, 'Implement Stripe Integration');
      expect(g2AfterMove.tasks.first.goalId, 'g_2');
      expect(g2AfterMove.tasks.first.priority, AppPriority.high);
    });
  });
}
