import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';
import 'package:life_daily_app/core/storage/memory_storage.dart';
import 'package:life_daily_app/features/auth/models/app_user.dart';
import 'package:life_daily_app/features/auth/services/i_auth_service.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/models/board_item.dart';
import 'package:life_daily_app/features/goals/models/daily_task_groups.dart';
import 'package:life_daily_app/features/goals/models/goal_category.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';
import 'package:life_daily_app/features/goals/models/goal_task.dart';
import 'package:life_daily_app/features/goals/repositories/i_goal_repository.dart';
import 'package:life_daily_app/features/goals/widgets/tasks_phone_board.dart';

import '../../helpers/fake_auth_service.dart';

class _FakeGoalRepository implements IGoalRepository {
  List<GoalModel> goals = [];
  int createCalls = 0;

  @override
  Future<List<GoalCategory>> fetchCategories(String ownerId) async => [];

  @override
  Future<List<GoalModel>> fetch(String ownerId) async => [...goals];

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
    createCalls++;
    final now = DateTime.now();
    final goal = GoalModel(
      id: 'g_$createCalls',
      ownerId: ownerId,
      title: title,
      details: details,
      kind: kind,
      startsAt: startsAt,
      dueAt: dueAt,
      category: category,
      status: GoalStatus.notStarted,
      checkIns: const [],
      createdAt: now,
      updatedAt: now,
    );
    goals.add(goal);
    return goal;
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
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateCategory(GoalCategory category) async {}

  @override
  Future<void> syncAfterLogin(String ownerId) async {}
}

GoalModel _goal(
  String id, {
  String title = 'Goal',
  List<GoalTask> tasks = const [],
}) {
  final now = DateTime.now();
  return GoalModel(
    id: id,
    ownerId: 'user_1',
    title: title,
    details: '',
    kind: GoalKind.once,
    startsAt: now,
    dueAt: now.add(const Duration(days: 30)),
    category: 'work',
    status: GoalStatus.inProgress,
    checkIns: const [],
    createdAt: now,
    updatedAt: now,
    tasks: tasks,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeGoalRepository repo;
  late GoalsController controller;

  setUp(() {
    Get.reset();
    Get.put<IAuthService>(
      FakeAuthService()
        ..user = const AppUser(uid: 'user_1', isAnonymous: false),
    );
    final storage = MemoryStorage();
    Get.put<IStorage>(storage);
    repo = _FakeGoalRepository();
    controller = GoalsController(repo, storage);
  });

  group('General tasks inbox', () {
    test('is created once and reused for tasks without a goal', () async {
      repo.goals = [_goal('g_real', title: 'Learn Spanish')];
      await controller.load();

      await controller.quickAddTask(title: 'Buy milk');
      await controller.quickAddTask(title: 'Call mom');

      expect(repo.createCalls, 1);
      final inbox = controller.inboxGoal!;
      expect(inbox.isInbox, isTrue);
      expect(inbox.tasks.map((t) => t.title), ['Buy milk', 'Call mom']);
      expect(controller.goalById('g_real')!.tasks, isEmpty);
    });

    test('concurrent quick adds still create a single inbox', () async {
      await controller.load();

      await Future.wait([controller.ensureInbox(), controller.ensureInbox()]);

      expect(repo.createCalls, 1);
    });

    test('is hidden from goal lists and counts', () async {
      repo.goals = [_goal('g_real', title: 'Run a marathon')];
      await controller.load();
      await controller.ensureInbox();

      expect(controller.goals.length, 2);
      expect(controller.scopedGoals.map((g) => g.id), ['g_real']);
      expect(controller.filteredGoals.map((g) => g.id), ['g_real']);
      expect(controller.totalCount, 1);
      final byStatus = controller.goalsByStatus.values.expand((l) => l);
      expect(byStatus.any((g) => g.isInbox), isFalse);
    });

    test('legacy "المهام العامة" goal becomes the inbox on load', () async {
      repo.goals = [_goal('g_legacy', title: 'المهام العامة')];
      await controller.load();
      await Future<void>.delayed(Duration.zero);

      expect(controller.inboxGoal?.id, 'g_legacy');
      expect(controller.scopedGoals, isEmpty);
      await controller.quickAddTask(title: 'Pay bills');
      expect(repo.createCalls, 0);
    });

    test('isInbox survives toMap/fromMap', () {
      final inbox = _goal('g_inbox').copyWith(isInbox: true);
      final restored = GoalModel.fromMap('g_inbox', inbox.toMap());
      expect(restored.isInbox, isTrue);
      expect(GoalModel.fromMap('x', _goal('x').toMap()).isInbox, isFalse);
    });
  });

  group('dailyTaskGroups', () {
    final today = DateTime(2026, 10, 5);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    setUp(() async {
      repo.goals = [
        _goal(
          'g1',
          tasks: [
            GoalTask(id: 'late_open', title: 'Late', dueDate: yesterday),
            GoalTask(
              id: 'late_done',
              title: 'Late done',
              dueDate: yesterday,
              status: GoalTaskStatus.done,
            ),
            GoalTask(id: 'due_today', title: 'Today', dueDate: today),
            GoalTask(id: 'due_tomorrow', title: 'Tomorrow', dueDate: tomorrow),
            const GoalTask(id: 'undated', title: 'Whenever'),
          ],
        ),
      ];
      await controller.load();
    });

    List<String> ids(List<GoalTaskEntry> items) =>
        items.map((e) => e.task.id).toList();

    test('splits today into overdue, scheduled and anytime', () {
      final groups = controller.dailyTaskGroups(today, now: today);
      expect(ids(groups.overdue), ['late_open']);
      expect(ids(groups.scheduled), ['due_today']);
      expect(ids(groups.anytime), ['undated']);
      expect(groups.total, 3);
    });

    test('other days only show tasks scheduled for that day', () {
      final groups = controller.dailyTaskGroups(tomorrow, now: today);
      expect(groups.overdue, isEmpty);
      expect(ids(groups.scheduled), ['due_tomorrow']);
      expect(groups.anytime, isEmpty);
    });
  });

  group('Unified board', () {
    List<String> keys(List<BoardItem> items) =>
        items.map((i) => i.key).toList();

    test('mixes big tasks and standalone tasks in shared columns', () async {
      repo.goals = [
        _goal(
          'g_todo',
          tasks: const [GoalTask(id: 'inside', title: 'Step')],
        ).copyWith(status: GoalStatus.notStarted),
        _goal('g_wait').copyWith(status: GoalStatus.pending),
        _goal('g_old').copyWith(status: GoalStatus.archived),
        _goal(
          'g_inbox',
          tasks: const [
            GoalTask(id: 'loose', title: 'Loose', status: GoalTaskStatus.done),
          ],
        ).copyWith(isInbox: true),
      ];
      await controller.load();

      final board = controller.boardItems;
      expect(keys(board[GoalTaskStatus.todo]!), ['goal_g_todo']);
      expect(keys(board[GoalTaskStatus.pending]!), ['goal_g_wait']);
      expect(keys(board[GoalTaskStatus.done]!), ['task_loose']);
      expect(controller.archivedGoals.map((g) => g.id), ['g_old']);
    });

    test('dragging a big task sets the matching goal status', () async {
      repo.goals = [_goal('g1')];
      await controller.load();

      await controller.moveBoardItem(
        GoalBoardItem(controller.goalById('g1')!),
        GoalTaskStatus.pending,
      );
      expect(controller.goalById('g1')!.status, GoalStatus.pending);
    });

    test('section filter applies to big tasks and standalone tasks', () async {
      repo.goals = [
        _goal('g_work'),
        _goal(
          'g_inbox',
          tasks: const [
            GoalTask(id: 'home_task', title: 'Dishes', categoryId: 'family'),
          ],
        ).copyWith(isInbox: true),
      ];
      await controller.load();

      controller.selectCategory('family');
      final all = controller.boardItems.values.expand((l) => l);
      expect(keys(all.toList()), ['task_home_task']);
    });
  });

  testWidgets('phone board shows one status tab at a time', (tester) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    repo.goals = [
      _goal(
        'g1',
        title: 'GYM',
        tasks: const [GoalTask(id: 'step', title: 'Warm up')],
      ).copyWith(status: GoalStatus.notStarted),
      _goal(
        'g_inbox',
        tasks: const [GoalTask(id: 'loose', title: 'Buy milk')],
      ).copyWith(isInbox: true),
    ];
    await tester.runAsync(controller.load);

    Get.put(controller);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GetBuilder<GoalsController>(
            id: 'goals',
            builder: (c) => Builder(
              builder: (context) => CustomScrollView(
                slivers: TasksPhoneBoard.slivers(context, c),
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('GYM'), findsOneWidget);
    expect(find.text('Buy milk'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.checklist_rounded).first);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(TextField), findsOneWidget);

    controller.selectBoardTab(GoalTaskStatus.done);
    await tester.pump();
    expect(find.text('GYM'), findsNothing);
  });

  group('Checklist', () {
    setUp(() async {
      repo.goals = [
        _goal(
          'g1',
          tasks: const [GoalTask(id: 't1', title: 'Pack')],
        ),
      ];
      await controller.load();
    });

    GoalTask task() => controller.goalById('g1')!.tasks.single;

    test('checking items never changes the task status', () async {
      await controller.addSubtask(controller.goalById('g1')!, 't1', 'Shoes');
      await controller.addSubtask(controller.goalById('g1')!, 't1', 'Socks');
      for (final item in task().subtasks) {
        await controller.toggleSubtask(
          controller.goalById('g1')!,
          't1',
          item.id,
        );
      }
      expect(task().subtasks.every((s) => s.isCompleted), isTrue);
      expect(task().status, GoalTaskStatus.todo);

      await controller.changeTaskStatus(
        controller.goalById('g1')!,
        't1',
        GoalTaskStatus.done,
      );
      await controller.addSubtask(controller.goalById('g1')!, 't1', 'Hat');
      expect(task().status, GoalTaskStatus.done);
    });
  });

  test('signing out clears the account data from memory', () async {
    repo.goals = [
      _goal(
        'g1',
        tasks: const [GoalTask(id: 't', title: 'T')],
      ),
    ];
    await controller.load();
    controller.selectCategory('work');
    expect(controller.goals, isNotEmpty);

    controller.clearAccountData();
    expect(controller.goals, isEmpty);
    expect(controller.categories, isEmpty);
    expect(controller.selectedCategoryId, isNull);
    expect(
      controller.boardItems.values.every((items) => items.isEmpty),
      isTrue,
    );
  });

  group('Goal progress', () {
    GoalModel withTasks(GoalStatus status) => _goal(
      'g1',
      tasks: const [
        GoalTask(id: 'a', title: 'A', status: GoalTaskStatus.done),
        GoalTask(id: 'b', title: 'B'),
      ],
    ).copyWith(status: status);

    test('follows finished tasks whatever the goal status', () {
      for (final status in GoalStatus.values) {
        final goal = withTasks(status);
        expect(goal.progressPercent, 50, reason: status.name);
        expect(goal.overallSuccessPercent, 50, reason: status.name);
      }
    });

    test('a habit goal with tasks also follows its tasks', () {
      final habit = _goal(
        'g1',
        tasks: const [
          GoalTask(id: 'a', title: 'A', status: GoalTaskStatus.done),
          GoalTask(id: 'b', title: 'B', status: GoalTaskStatus.done),
        ],
      ).copyWith(kind: GoalKind.habit, status: GoalStatus.notStarted);
      expect(habit.progressPercent, 100);
      expect(habit.overallSuccessPercent, 100);
    });

    test('a goal without tasks counts only when done', () {
      expect(_goal('g1').copyWith(status: GoalStatus.done).progress, 1);
      expect(_goal('g1').copyWith(status: GoalStatus.inProgress).progress, 0);
    });
  });

  group('Task sections', () {
    test('categoryId survives toMap/fromMap', () {
      const task = GoalTask(id: 't', title: 'Study', categoryId: 'cat_study');
      expect(GoalTask.fromMap(task.toMap()).categoryId, 'cat_study');
      expect(task.copyWith(clearCategory: true).categoryId, isNull);
    });

    test('quick add stores the section on the task', () async {
      await controller.load();
      await controller.quickAddTask(title: 'Read', categoryId: 'cat_study');
      expect(controller.inboxGoal!.tasks.single.categoryId, 'cat_study');
    });

    test(
      'board filters by own section, falling back to goal section',
      () async {
        repo.goals = [
          _goal(
            'g_work',
            tasks: const [
              GoalTask(id: 'inherits_work', title: 'Report'),
              GoalTask(id: 'own_home', title: 'Dishes', categoryId: 'family'),
            ],
          ),
        ];
        await controller.load();

        List<String> idsFor(String? section) => controller
            .tasksByStatus(filterCategoryId: section)
            .values
            .expand((l) => l)
            .map((e) => e.task.id)
            .toList();

        expect(idsFor('work'), ['inherits_work']);
        expect(idsFor('family'), ['own_home']);
        expect(idsFor(null), ['inherits_work', 'own_home']);
      },
    );
  });
}
