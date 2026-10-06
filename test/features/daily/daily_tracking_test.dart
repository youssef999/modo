import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
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
import 'package:life_daily_app/features/goals/models/goal_tracker.dart';
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

  group('Daily Tracking Hub Tests', () {
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
      'habitsForDate, isHabitDoneForDate, and toggleHabitForDate work correctly',
      () async {
        final today = DateTime.now();
        final habit = GoalModel(
          id: 'h1',
          ownerId: 'user_123',
          title: 'Morning Run',
          details: 'Run 5km',
          kind: GoalKind.habit,
          startsAt: today.subtract(const Duration(days: 5)),
          dueAt: today.add(const Duration(days: 20)),
          category: 'fitness',
          status: GoalStatus.inProgress,
          checkIns: [
            GoalModel.dateKey(today.subtract(const Duration(days: 1))),
          ],
          createdAt: today,
          updatedAt: today,
          trackers: [
            const GoalTracker(
              id: 't1',
              title: 'Kilometers',
              kind: GoalTrackerKind.numeric,
              current: 3,
              target: 5,
              unit: 'km',
            ),
          ],
        );

        goalRepo.goals = [habit];
        await goalsController.load();

        final habits = goalsController.habitsForDate(today);
        expect(habits.length, equals(1));
        expect(habits.first.title, equals('Morning Run'));

        // Check not done yet today
        expect(goalsController.isHabitDoneForDate(habit, today), isFalse);

        // Toggle check-in for today
        await goalsController.toggleHabitForDate(habit, today);
        expect(
          goalsController.isHabitDoneForDate(
            goalsController.goals.first,
            today,
          ),
          isTrue,
        );

        // Toggle again to uncheck
        await goalsController.toggleHabitForDate(
          goalsController.goals.first,
          today,
        );
        expect(
          goalsController.isHabitDoneForDate(
            goalsController.goals.first,
            today,
          ),
          isFalse,
        );
      },
    );

    test(
      'stepTracker increments and decrements numeric tracker values safely',
      () async {
        final today = DateTime.now();
        final goal = GoalModel(
          id: 'g1',
          ownerId: 'user_123',
          title: 'Reading',
          details: '',
          kind: GoalKind.habit,
          startsAt: today,
          dueAt: today.add(const Duration(days: 10)),
          category: 'personal',
          status: GoalStatus.inProgress,
          checkIns: const [],
          createdAt: today,
          updatedAt: today,
          trackers: [
            const GoalTracker(
              id: 'tr_read',
              title: 'Pages',
              kind: GoalTrackerKind.numeric,
              current: 5,
              target: 10,
              unit: 'pages',
            ),
          ],
        );

        goalRepo.goals = [goal];
        await goalsController.load();

        // Step increment
        await goalsController.stepTracker(
          goalsController.goals.first,
          'tr_read',
          true,
        );
        expect(goalsController.goals.first.trackers.first.current, equals(6.0));

        // Step decrement
        await goalsController.stepTracker(
          goalsController.goals.first,
          'tr_read',
          false,
        );
        expect(goalsController.goals.first.trackers.first.current, equals(5.0));
      },
    );

    test(
      'tasksForDate filters scheduled and unscheduled tasks for date',
      () async {
        final today = DateTime.now();
        final tomorrow = today.add(const Duration(days: 1));

        final goal = GoalModel(
          id: 'g_tasks',
          ownerId: 'user_123',
          title: 'Work Project',
          details: '',
          kind: GoalKind.once,
          startsAt: today,
          dueAt: today.add(const Duration(days: 7)),
          category: 'work',
          status: GoalStatus.inProgress,
          checkIns: const [],
          createdAt: today,
          updatedAt: today,
          tasks: [
            GoalTask(
              id: 't_today',
              title: 'Fix issue',
              status: GoalTaskStatus.todo,
              dueDate: today,
              dueTime: '09:30 AM',
            ),
            GoalTask(
              id: 't_tomorrow',
              title: 'Deploy to staging',
              status: GoalTaskStatus.todo,
              dueDate: tomorrow,
              dueTime: '02:00 PM',
            ),
            const GoalTask(
              id: 't_unscheduled',
              title: 'Review pull request',
              status: GoalTaskStatus.todo,
            ),
          ],
        );

        goalRepo.goals = [goal];
        await goalsController.load();

        final todayTasks = goalsController.tasksForDate(today);
        // Scheduled for today + unscheduled shown on today
        expect(
          todayTasks.map((item) => item.task.id),
          containsAll(['t_today', 't_unscheduled']),
        );
        expect(
          todayTasks.map((item) => item.task.id),
          isNot(contains('t_tomorrow')),
        );

        // Tomorrow tasks should only contain t_tomorrow
        final tomorrowTasks = goalsController.tasksForDate(tomorrow);
        expect(
          tomorrowTasks.map((item) => item.task.id),
          contains('t_tomorrow'),
        );
        expect(
          tomorrowTasks.map((item) => item.task.id),
          isNot(contains('t_today')),
        );
      },
    );

    test('dailyProgress computes completion counts and percentage', () async {
      final today = DateTime.now();
      final habit = GoalModel(
        id: 'h_prog',
        ownerId: 'user_123',
        title: 'Drink Water',
        details: '',
        kind: GoalKind.habit,
        startsAt: today,
        dueAt: today.add(const Duration(days: 10)),
        category: 'health',
        status: GoalStatus.inProgress,
        checkIns: [GoalModel.dateKey(today)], // Done
        createdAt: today,
        updatedAt: today,
      );

      final taskGoal = GoalModel(
        id: 'g_prog',
        ownerId: 'user_123',
        title: 'Tasks Goal',
        details: '',
        kind: GoalKind.once,
        startsAt: today,
        dueAt: today.add(const Duration(days: 10)),
        category: 'work',
        status: GoalStatus.inProgress,
        checkIns: const [],
        createdAt: today,
        updatedAt: today,
        tasks: [
          GoalTask(
            id: 'tk1',
            title: 'Task 1',
            status: GoalTaskStatus.done,
            dueDate: today,
          ),
          GoalTask(
            id: 'tk2',
            title: 'Task 2',
            status: GoalTaskStatus.todo,
            dueDate: today,
          ),
        ],
      );

      goalRepo.goals = [habit, taskGoal];
      await goalsController.load();

      final progress = goalsController.dailyProgress(today);
      // Total = 1 habit + 2 tasks = 3. Completed = 1 habit + 1 task = 2.
      expect(progress.total, equals(3));
      expect(progress.completed, equals(2));
      expect(progress.progress, closeTo(2 / 3, 0.01));
    });

    test(
      'Finance daily metrics: entriesForDate, dailySpend, dailyIncome, commitments',
      () async {
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));

        financeRepo.entries = [
          FinanceEntry(
            id: 'e1',
            ownerId: 'user_123',
            kind: FinanceKind.expense,
            title: 'Lunch',
            amount: 25.0,
            categoryId: 'food',
            occurredAt: today,
            note: '',
            createdAt: today,
            updatedAt: today,
          ),
          FinanceEntry(
            id: 'e2',
            ownerId: 'user_123',
            kind: FinanceKind.expense,
            title: 'Coffee',
            amount: 5.0,
            categoryId: 'food',
            occurredAt: today,
            note: '',
            createdAt: today,
            updatedAt: today,
          ),
          FinanceEntry(
            id: 'e3',
            ownerId: 'user_123',
            kind: FinanceKind.income,
            title: 'Freelance payment',
            amount: 100.0,
            categoryId: 'income',
            occurredAt: today,
            note: '',
            createdAt: today,
            updatedAt: today,
          ),
          FinanceEntry(
            id: 'e4',
            ownerId: 'user_123',
            kind: FinanceKind.expense,
            title: 'Groceries',
            amount: 50.0,
            categoryId: 'food',
            occurredAt: yesterday,
            note: '',
            createdAt: yesterday,
            updatedAt: yesterday,
          ),
        ];

        await financeController.load();

        final dayEntries = financeController.entriesForDate(today);
        expect(dayEntries.length, equals(3));

        expect(financeController.dailySpendForDate(today), equals(30.0));
        expect(financeController.dailyIncomeForDate(today), equals(100.0));

        // Commitments due today
        await financeController.addCommitment(
          title: 'Gym Membership',
          amount: 40.0,
          dueDay: today.day,
        );
        await financeController.addCommitment(
          title: 'Internet Bill',
          amount: 60.0,
          dueDay: (today.day + 5) % 28 + 1,
        );

        final dueToday = financeController.commitmentsDueOnDate(today);
        expect(dueToday.length, equals(1));
        expect(dueToday.first.title, equals('Gym Membership'));
      },
    );
  });
}
