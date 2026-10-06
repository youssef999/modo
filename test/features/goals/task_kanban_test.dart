import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/models/app_priority.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';
import 'package:life_daily_app/features/auth/models/app_user.dart';
import 'package:life_daily_app/features/auth/services/i_auth_service.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/finance/models/finance_category.dart';
import 'package:life_daily_app/features/finance/models/finance_category_role.dart';
import 'package:life_daily_app/features/finance/models/finance_entry.dart';
import 'package:life_daily_app/features/finance/models/finance_month_plan.dart';
import 'package:life_daily_app/features/finance/repositories/i_finance_repository.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/models/goal_category.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';
import 'package:life_daily_app/features/goals/models/goal_task.dart';
import 'package:life_daily_app/features/goals/repositories/i_goal_repository.dart';

class _FakeAuthService implements IAuthService {
  AppUser? _user = const AppUser(
    uid: 'user_123',
    isAnonymous: false,
    email: 'user@example.com',
    displayName: 'Test User',
  );

  @override
  AppUser? get currentUser => _user;

  @override
  Future<AppUser?> restoreSession() async => currentUser;

  @override
  Future<AppUser> ensureAnonymousSession() async => _user!;

  @override
  Future<AppUser> continueWithGoogle() async => _user!;

  @override
  Future<AppUser> continueWithApple() async => _user!;

  @override
  Future<AppUser> signInWithEmail(String email, String password) async =>
      _user!;

  @override
  Future<AppUser> registerWithEmail(String email, String password) async =>
      _user!;

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async {
    _user = null;
  }
}

class _FakeStorage implements IStorage {
  final Map<String, dynamic> _data = {};

  @override
  T? read<T>(String key) => _data[key] as T?;

  @override
  Future<void> write(String key, dynamic value) async {
    _data[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _data.remove(key);
  }
}

class _FakeGoalRepository implements IGoalRepository {
  List<GoalModel> goals = [];
  List<GoalCategory> categories = [];

  @override
  Future<List<GoalCategory>> fetchCategories(String ownerId) async =>
      categories;

  @override
  Future<List<GoalModel>> fetch(String ownerId) async => goals;

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
    final g = GoalModel(
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
    goals.add(g);
    return g;
  }

  @override
  Future<void> update(GoalModel goal) async {
    final index = goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) goals[index] = goal;
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
      id: 'cat_1',
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

class _FakeFinanceRepository implements IFinanceRepository {
  List<FinanceCategory> categories = [];
  List<FinanceEntry> entries = [];
  List<FinanceMonthPlan> plans = [];

  @override
  Future<List<FinanceCategory>> fetchCategories(String ownerId) async =>
      categories;

  @override
  Future<List<FinanceEntry>> fetchEntries(String ownerId) async => entries;

  @override
  Future<List<FinanceMonthPlan>> fetchMonthPlans(String ownerId) async => plans;

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
    final entry = FinanceEntry(
      id: 'e_${DateTime.now().millisecondsSinceEpoch}',
      ownerId: ownerId,
      kind: kind,
      title: title,
      amount: amount,
      categoryId: categoryId,
      occurredAt: occurredAt,
      note: note,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    entries.add(entry);
    return entry;
  }

  @override
  Future<FinanceCategory> addCategory({
    required String ownerId,
    required String name,
    FinanceCategoryRole role = FinanceCategoryRole.spend,
    String iconKey = 'star',
  }) async {
    final cat = FinanceCategory(
      id: 'fc_1',
      ownerId: ownerId,
      name: name,
      role: role,
      iconKey: iconKey,
      builtInKey: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    categories.add(cat);
    return cat;
  }

  @override
  Future<void> deleteEntry(String ownerId, String id) async {}

  @override
  Future<FinanceMonthPlan> saveMonthPlan(FinanceMonthPlan plan) async {
    plans.add(plan);
    return plan;
  }

  @override
  Future<void> syncAfterLogin(String ownerId) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Task & Finance Kanban Board Tests', () {
    late GoalsController goalsController;
    late FinanceController financeController;
    late _FakeGoalRepository goalRepo;
    late _FakeFinanceRepository financeRepo;
    late _FakeStorage storage;

    setUp(() {
      Get.reset();
      Get.put<IAuthService>(_FakeAuthService());
      storage = _FakeStorage();
      Get.put<IStorage>(storage);

      goalRepo = _FakeGoalRepository();
      goalsController = GoalsController(goalRepo, storage);

      financeRepo = _FakeFinanceRepository();
      financeController = FinanceController(financeRepo, storage);
    });

    test(
      'tasksByStatus categorizes tasks across 4 columns (todo, pending, inProgress, done)',
      () async {
        final now = DateTime.now();
        final goal = GoalModel(
          id: 'g_board',
          ownerId: 'user_123',
          title: 'Product Redesign',
          details: 'Notion style board',
          kind: GoalKind.once,
          startsAt: now,
          dueAt: now.add(const Duration(days: 30)),
          category: 'work',
          status: GoalStatus.inProgress,
          checkIns: const [],
          createdAt: now,
          updatedAt: now,
          tasks: [
            const GoalTask(
              id: 't1',
              title: 'Task 1',
              status: GoalTaskStatus.todo,
            ),
            const GoalTask(
              id: 't2',
              title: 'Task 2',
              status: GoalTaskStatus.pending,
            ),
            const GoalTask(
              id: 't3',
              title: 'Task 3',
              status: GoalTaskStatus.inProgress,
            ),
            const GoalTask(
              id: 't4',
              title: 'Task 4',
              status: GoalTaskStatus.done,
            ),
          ],
        );

        goalRepo.goals = [goal];
        await goalsController.load();

        final board = goalsController.tasksByStatus();
        expect(board[GoalTaskStatus.todo]?.length, equals(1));
        expect(board[GoalTaskStatus.pending]?.length, equals(1));
        expect(board[GoalTaskStatus.inProgress]?.length, equals(1));
        expect(board[GoalTaskStatus.done]?.length, equals(1));

        expect(
          board[GoalTaskStatus.pending]!.first.task.title,
          equals('Task 2'),
        );
      },
    );

    test(
      'changeTaskStatus moves a task from todo to pending to done',
      () async {
        final now = DateTime.now();
        final goal = GoalModel(
          id: 'g_move',
          ownerId: 'user_123',
          title: 'Goal Move',
          details: '',
          kind: GoalKind.once,
          startsAt: now,
          dueAt: now.add(const Duration(days: 30)),
          category: 'work',
          status: GoalStatus.inProgress,
          checkIns: const [],
          createdAt: now,
          updatedAt: now,
          tasks: [
            const GoalTask(
              id: 'task_target',
              title: 'Design Review',
              status: GoalTaskStatus.todo,
            ),
          ],
        );

        goalRepo.goals = [goal];
        await goalsController.load();

        // Move to pending
        await goalsController.changeTaskStatus(
          goal,
          'task_target',
          GoalTaskStatus.pending,
        );
        var updatedGoal = goalsController.goalById('g_move')!;
        expect(updatedGoal.tasks.first.status, equals(GoalTaskStatus.pending));

        // Move to inProgress
        await goalsController.changeTaskStatus(
          updatedGoal,
          'task_target',
          GoalTaskStatus.inProgress,
        );
        updatedGoal = goalsController.goalById('g_move')!;
        expect(
          updatedGoal.tasks.first.status,
          equals(GoalTaskStatus.inProgress),
        );

        // Move to done
        await goalsController.changeTaskStatus(
          updatedGoal,
          'task_target',
          GoalTaskStatus.done,
        );
        updatedGoal = goalsController.goalById('g_move')!;
        expect(updatedGoal.tasks.first.status, equals(GoalTaskStatus.done));
      },
    );

    test(
      'quickAddTask adds task directly with column status and priority',
      () async {
        final now = DateTime.now();
        final goal = GoalModel(
          id: 'g_quick',
          ownerId: 'user_123',
          title: 'Quick Add Goal',
          details: '',
          kind: GoalKind.once,
          startsAt: now,
          dueAt: now.add(const Duration(days: 30)),
          category: 'work',
          status: GoalStatus.inProgress,
          checkIns: const [],
          createdAt: now,
          updatedAt: now,
        );

        goalRepo.goals = [goal];
        await goalsController.load();

        await goalsController.quickAddTask(
          goalId: 'g_quick',
          title: 'Urgent Bugfix',
          status: GoalTaskStatus.pending,
          priority: AppPriority.urgent,
          dueTime: '11:00 AM',
        );

        final updated = goalsController.goalById('g_quick')!;
        expect(updated.tasks.length, equals(1));
        final newTask = updated.tasks.first;
        expect(newTask.title, equals('Urgent Bugfix'));
        expect(newTask.status, equals(GoalTaskStatus.pending));
        expect(newTask.priority, equals(AppPriority.urgent));
        expect(newTask.dueTime, equals('11:00 AM'));
      },
    );

    test(
      'Finance commitmentsByStatus groups commitments into upcoming, dueToday, and paid',
      () async {
        final todayDay = DateTime.now().day;

        await financeController.load();

        await financeController.addCommitment(
          title: 'Electricity Bill',
          amount: 80.0,
          dueDay: todayDay,
        );
        await financeController.addCommitment(
          title: 'Next Week Rent',
          amount: 500.0,
          dueDay: (todayDay + 7) % 28 + 1,
        );
        await financeController.addCommitment(
          title: 'Car Loan',
          amount: 250.0,
          dueDay: 1,
        );

        // Mark car loan as paid
        final carLoan = financeController.commitments.firstWhere(
          (c) => c.title == 'Car Loan',
        );
        await financeController.toggleCommitmentPaid(carLoan);

        final grouped = financeController.commitmentsByStatus;
        expect(grouped['dueToday']?.length, equals(1));
        expect(grouped['dueToday']?.first.title, equals('Electricity Bill'));

        expect(grouped['upcoming']?.length, equals(1));
        expect(grouped['upcoming']?.first.title, equals('Next Week Rent'));

        expect(grouped['paid']?.length, equals(1));
        expect(grouped['paid']?.first.title, equals('Car Loan'));
      },
    );
  });
}
