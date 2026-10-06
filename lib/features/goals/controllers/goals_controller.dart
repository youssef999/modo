import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/constants/storage_keys.dart';
import 'package:life_daily_app/core/models/app_priority.dart';
import 'package:life_daily_app/core/models/app_view_mode.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';
import 'package:life_daily_app/features/auth/services/i_auth_service.dart';
import 'package:life_daily_app/features/notifications/controllers/daily_reminder_controller.dart';

import '../models/board_item.dart';
import '../models/daily_task_groups.dart';
import '../models/goal_category.dart';
import '../models/goal_invite.dart';
import '../models/goal_member.dart';
import '../models/goal_model.dart';
import '../models/goal_sub_task.dart';
import '../models/goal_task.dart';
import '../models/goal_tracker.dart';
import '../repositories/i_goal_invite_repository.dart';
import '../repositories/i_goal_repository.dart';

class GoalsController extends GetxController {
  GoalsController(this._repository, this._storage, {this.inviteRepository});

  final IGoalRepository _repository;
  final IStorage _storage;
  final IGoalInviteRepository? inviteRepository;

  List<GoalModel> goals = [];
  List<GoalCategory> categories = [];
  List<GoalInvite> pendingInvites = [];
  String? selectedCategoryId;
  AppViewMode viewMode = AppViewMode.list;
  bool isLoading = true;

  String get ownerId {
    final uid = Get.find<IAuthService>().currentUser?.uid;
    if (uid != null && uid.isNotEmpty) return uid;
    return 'local_user';
  }

  GoalStatus? statusFilter; // null = show all

  void setStatusFilter(GoalStatus? status) {
    statusFilter = status;
    update(['goals']);
  }

  List<GoalModel> get filteredGoals {
    var result = scopedGoals;
    if (statusFilter != null) {
      result = result.where((g) => g.status == statusFilter).toList();
    }
    return result;
  }

  Map<GoalStatus, List<GoalModel>> get goalsByStatus {
    final map = <GoalStatus, List<GoalModel>>{
      for (final s in GoalStatus.values) s: [],
    };
    for (final goal in scopedGoals) {
      map[goal.status]!.add(goal);
    }
    for (final list in map.values) {
      list.sort((a, b) => a.boardOrder.compareTo(b.boardOrder));
    }
    return map;
  }

  /// Every goal except the hidden General tasks inbox.
  List<GoalModel> get realGoals => goals.where((g) => !g.isInbox).toList();

  String goalTitle(GoalModel goal) =>
      goal.isInbox ? LocaleKeys.generalTasks.tr : goal.title;

  GoalModel? get inboxGoal {
    for (final goal in goals) {
      if (goal.isInbox) return goal;
    }
    return null;
  }

  List<GoalModel> get scopedGoals {
    final folderId = selectedCategoryId;
    final source = realGoals;
    if (folderId == null || folderId.isEmpty) return source;
    return source.where((goal) => goal.category == folderId).toList();
  }

  List<GoalModel> get visibleGoals => filteredGoals;

  List<GoalModel> get activeGoals {
    return scopedGoals.where((goal) => goal.isActive).toList();
  }

  List<GoalModel> get doneGoals {
    return scopedGoals.where((goal) => goal.isDone || goal.isArchived).toList();
  }

  int get doneCount => doneGoals.length;

  int get totalCount => realGoals.length;

  int statusCount(GoalStatus status) {
    return scopedGoals.where((g) => g.status == status).length;
  }

  double get progress {
    final source = realGoals;
    if (source.isEmpty) return 0;
    final sum = source.fold<double>(0, (value, goal) => value + goal.progress);
    return sum / source.length;
  }

  int get progressPercent => (progress * 100).round();

  @override
  void onInit() {
    super.onInit();
    _loadViewMode();
    load();
  }

  void _loadViewMode() {
    final saved = _storage.read<String>(StorageKeys.goalsViewMode);
    viewMode =
        AppViewMode.values.firstWhereOrNull((m) => m.name == saved) ??
        AppViewMode.list;
  }

  void setViewMode(AppViewMode mode) {
    if (viewMode == mode) return;
    viewMode = mode;
    _storage.write(StorageKeys.goalsViewMode, mode.name);
    update(['goals']);
  }

  bool get isGridView => viewMode == AppViewMode.grid;

  int _loadGeneration = 0;

  Future<void> load() async {
    final generation = ++_loadGeneration;
    isLoading = true;
    update(['goals']);
    final owner = ownerId;
    if (owner.isEmpty) {
      isLoading = false;
      update(['goals']);
      return;
    }
    final freshCategories = await _repository.fetchCategories(owner);
    final freshGoals = await _repository.fetch(owner);
    if (generation != _loadGeneration || isClosed) return;
    categories = freshCategories;
    goals = freshGoals;
    isLoading = false;
    update(['goals']);
    _refreshReminder();
    _migrateLegacyInbox();
    // Load pending invites in the background (non-blocking)
    loadPendingInvites();
  }

  static const _legacyInboxTitle = 'المهام العامة';

  Future<void> _migrateLegacyInbox() async {
    if (inboxGoal != null) return;
    for (final goal in goals) {
      if (goal.title.trim() == _legacyInboxTitle) {
        await editGoal(goal.copyWith(isInbox: true));
        return;
      }
    }
  }

  Future<GoalModel>? _inboxCreation;

  Future<GoalModel> ensureInbox() {
    final existing = inboxGoal;
    if (existing != null) return Future.value(existing);
    return _inboxCreation ??= _createInbox().whenComplete(
      () => _inboxCreation = null,
    );
  }

  Future<GoalModel> _createInbox() async {
    final now = DateTime.now();
    final created = await _repository.create(
      ownerId: ownerId,
      title: LocaleKeys.generalTasks.tr,
      details: '',
      kind: GoalKind.once,
      startsAt: now,
      dueAt: DateTime(now.year + 10, now.month, now.day),
      category: categories.isNotEmpty ? categories.first.id : 'course',
    );
    final inbox = created.copyWith(isInbox: true);
    await _repository.update(inbox);
    goals = [...goals, inbox]..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return inbox;
  }

  Future<void> onAccountReady() async {
    await _repository.syncAfterLogin(ownerId);
    await load();
  }

  void selectCategory(String? categoryId) {
    selectedCategoryId = categoryId;
    update(['goals']);
  }

  int folderCount(String folderId) {
    return realGoals.where((goal) => goal.category == folderId).length;
  }

  List<String> folderTitles(String folderId) {
    return realGoals
        .where((goal) => goal.category == folderId)
        .map((goal) => goal.title)
        .take(3)
        .toList();
  }

  GoalCategory? categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  String categoryLabel(GoalCategory category) {
    if (category.name.trim().isNotEmpty) return category.name.trim();
    if (category.isBuiltIn) return category.labelKey.tr;
    return category.name;
  }

  String goalCategoryLabel(GoalModel goal) {
    final category = categoryById(goal.category);
    if (category != null) return categoryLabel(category);
    return LocaleKeys.goalCategory.tr;
  }

  Future<String?> addCategory(
    String name, {
    String iconKey = 'star',
    bool select = true,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;
    final category = await _repository.addCategory(
      ownerId: ownerId,
      name: trimmed,
      iconKey: iconKey,
    );
    categories = [...categories, category];
    if (select) selectedCategoryId = category.id;
    update(['goals']);
    return category.id;
  }

  Future<void> renameCategory(GoalCategory category, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > 40) return;
    final next = category.copyWith(name: trimmed);
    await _repository.updateCategory(next);
    final index = categories.indexWhere((item) => item.id == category.id);
    if (index == -1) return;
    categories[index] = next;
    update(['goals']);
  }

  Future<void> addGoal({
    required String title,
    required String details,
    required GoalKind kind,
    required DateTime startsAt,
    required DateTime dueAt,
    required String category,
    GoalStatus status = GoalStatus.notStarted,
    AppPriority priority = AppPriority.medium,
  }) async {
    var goal = await _repository.create(
      ownerId: ownerId,
      title: title.trim(),
      details: details.trim(),
      kind: kind,
      startsAt: startsAt,
      dueAt: dueAt,
      category: category,
    );
    if (status != GoalStatus.notStarted || priority != AppPriority.medium) {
      goal = goal.copyWith(status: status, priority: priority);
      await _repository.update(goal);
    }
    goals = [...goals, goal]..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    update(['goals']);
    _refreshReminder();
  }

  Future<void> changeGoalPriority(
    GoalModel goal,
    AppPriority newPriority,
  ) async {
    if (goal.priority == newPriority) return;
    final next = goal.copyWith(
      priority: newPriority,
      updatedAt: DateTime.now(),
    );
    await editGoal(next);
  }

  Future<void> editGoal(GoalModel goal) async {
    final next = goal.prunedCheckIns();
    await _repository.update(next);
    final index = goals.indexWhere((item) => item.id == next.id);
    if (index == -1) return;
    goals[index] = next;
    goals.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    update(['goals']);
    _refreshReminder();
  }

  Future<void> deleteGoal(GoalModel goal) async {
    await _repository.delete(ownerId, goal.id);
    goals = goals.where((item) => item.id != goal.id).toList();
    update(['goals']);
    _refreshReminder();
  }

  void _refreshReminder() {
    if (Get.isRegistered<DailyReminderController>()) {
      Get.find<DailyReminderController>().scheduleRefresh();
    }
  }

  Future<void> changeGoalStatus(GoalModel goal, GoalStatus newStatus) async {
    if (goal.status == newStatus) return;
    final next = goal.copyWith(status: newStatus, updatedAt: DateTime.now());
    await editGoal(next);
  }

  Future<void> reorderGoal(GoalModel goal, int newOrder) async {
    final next = goal.copyWith(boardOrder: newOrder, updatedAt: DateTime.now());
    await editGoal(next);
  }

  Future<void> changeTaskStatus(
    GoalModel goal,
    String taskId,
    GoalTaskStatus newStatus,
  ) async {
    final updatedTasks = goal.tasks.map((task) {
      if (task.id == taskId) {
        return task.copyWith(status: newStatus);
      }
      return task;
    }).toList();
    final next = goal.copyWith(tasks: updatedTasks, updatedAt: DateTime.now());
    await editGoal(next);
  }

  Future<void> changeTaskPriority(
    GoalModel goal,
    String taskId,
    AppPriority newPriority,
  ) async {
    final updatedTasks = goal.tasks.map((task) {
      if (task.id == taskId) {
        return task.copyWith(priority: newPriority);
      }
      return task;
    }).toList();
    final next = goal.copyWith(tasks: updatedTasks, updatedAt: DateTime.now());
    await editGoal(next);
  }

  Future<void> reassignTaskToGoal({
    required String fromGoalId,
    required String toGoalId,
    required String taskId,
  }) async {
    if (fromGoalId == toGoalId) return;
    final fromGoal = goalById(fromGoalId);
    final toGoal = goalById(toGoalId);
    if (fromGoal == null || toGoal == null) return;

    final taskIndex = fromGoal.tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;
    final taskToMove = fromGoal.tasks[taskIndex].copyWith(goalId: toGoalId);

    // Remove from source goal
    final updatedFromTasks = fromGoal.tasks
        .where((t) => t.id != taskId)
        .toList();
    final updatedFromGoal = fromGoal.copyWith(
      tasks: updatedFromTasks,
      updatedAt: DateTime.now(),
    );
    await editGoal(updatedFromGoal);

    // Add to target goal
    final updatedToGoal = toGoal.copyWith(
      tasks: [
        ...toGoal.tasks,
        taskToMove.copyWith(order: toGoal.tasks.length),
      ],
      updatedAt: DateTime.now(),
    );
    await editGoal(updatedToGoal);
  }

  Future<void> toggleDone(GoalModel goal) async {
    if (goal.isHabit) return;
    await changeGoalStatus(
      goal,
      goal.isDone ? GoalStatus.notStarted : GoalStatus.done,
    );
  }

  Future<void> toggleCheckIn(GoalModel goal, DateTime day) async {
    if (!goal.canLog(day)) return;
    final key = GoalModel.dateKey(day);
    final nextIns = {...goal.checkIns};
    if (nextIns.contains(key)) {
      nextIns.remove(key);
    } else {
      nextIns.add(key);
    }
    await _saveCheckIns(goal, nextIns);
  }

  Future<void> logCheckIn(GoalModel goal, DateTime day) async {
    if (!goal.canLog(day) || goal.isChecked(day)) return;
    await _saveCheckIns(goal, {...goal.checkIns, GoalModel.dateKey(day)});
  }

  Future<void> _saveCheckIns(GoalModel goal, Set<String> checkIns) async {
    final list = checkIns.toList()..sort();
    final next = goal.copyWith(checkIns: list, updatedAt: DateTime.now());
    final complete = next.completedDays >= next.plannedDays;
    await editGoal(
      next.copyWith(status: complete ? GoalStatus.done : GoalStatus.inProgress),
    );
  }

  GoalModel? goalById(String id) {
    for (final goal in goals) {
      if (goal.id == id) return goal;
    }
    return null;
  }

  Future<void> _updateTask(
    GoalModel goal,
    String taskId,
    GoalTask Function(GoalTask task) change,
  ) async {
    final current = goalById(goal.id) ?? goal;
    final updatedTasks = [
      for (final task in current.tasks) task.id == taskId ? change(task) : task,
    ];
    await editGoal(
      current.copyWith(tasks: updatedTasks, updatedAt: DateTime.now()),
    );
  }

  /// Adding an item to a finished task reopens it.
  Future<void> addSubtask(GoalModel goal, String taskId, String title) async {
    final clean = title.trim();
    if (clean.isEmpty) return;
    await _updateTask(goal, taskId, (task) {
      final item = GoalSubTask(
        id: '${DateTime.now().microsecondsSinceEpoch}',
        title: clean,
        order: task.subtasks.length,
      );
      return task.copyWith(
        subtasks: [...task.subtasks, item],
        status: task.status == GoalTaskStatus.done
            ? GoalTaskStatus.inProgress
            : task.status,
      );
    });
  }

  /// Checking items moves the task: all checked → done, some → in progress.
  Future<void> toggleSubtask(GoalModel goal, String taskId, String subId) {
    return _updateTask(goal, taskId, (task) {
      final items = [
        for (final s in task.subtasks)
          s.id == subId ? s.copyWith(isCompleted: !s.isCompleted) : s,
      ];
      final checked = items.where((s) => s.isCompleted).length;
      final status = checked == items.length
          ? GoalTaskStatus.done
          : (checked > 0 || task.status == GoalTaskStatus.done)
          ? (task.status == GoalTaskStatus.pending
                ? GoalTaskStatus.pending
                : GoalTaskStatus.inProgress)
          : task.status;
      return task.copyWith(subtasks: items, status: status);
    });
  }

  Future<void> deleteSubtask(GoalModel goal, String taskId, String subId) {
    return _updateTask(
      goal,
      taskId,
      (task) => task.copyWith(
        subtasks: task.subtasks.where((s) => s.id != subId).toList(),
      ),
    );
  }

  Future<void> toggleTask(GoalModel goal, String taskId) async {
    final updatedTasks = goal.tasks.map((task) {
      if (task.id == taskId) {
        return task.copyWith(
          status: task.isCompleted ? GoalTaskStatus.todo : GoalTaskStatus.done,
        );
      }
      return task;
    }).toList();
    final next = goal.copyWith(tasks: updatedTasks, updatedAt: DateTime.now());
    await editGoal(next);
  }

  Future<void> addTask(
    GoalModel goal,
    String title, {
    GoalTaskStatus status = GoalTaskStatus.todo,
    AppPriority priority = AppPriority.medium,
    String? assigneeId,
    String? assigneeEmail,
    String? assigneeName,
  }) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) return;
    final newTask = GoalTask(
      id: '${DateTime.now().microsecondsSinceEpoch}_${goal.tasks.length}',
      title: cleanTitle,
      status: status,
      priority: priority,
      goalId: goal.id,
      order: goal.tasks.length,
      assigneeId: assigneeId,
      assigneeEmail: assigneeEmail,
      assigneeName: assigneeName,
    );
    final next = goal.copyWith(
      tasks: [...goal.tasks, newTask],
      updatedAt: DateTime.now(),
    );
    await editGoal(next);
  }

  Future<void> deleteTask(GoalModel goal, String taskId) async {
    final updatedTasks = goal.tasks.where((t) => t.id != taskId).toList();
    final next = goal.copyWith(tasks: updatedTasks, updatedAt: DateTime.now());
    await editGoal(next);
  }

  Future<void> updateTrackerValue(
    GoalModel goal,
    String trackerId,
    double newValue, {
    int? milestoneIndex,
  }) async {
    final updatedTrackers = goal.trackers.map((tracker) {
      if (tracker.id == trackerId) {
        return tracker.copyWith(
          current: newValue,
          currentMilestoneIndex:
              milestoneIndex ?? tracker.currentMilestoneIndex,
        );
      }
      return tracker;
    }).toList();
    final next = goal.copyWith(
      trackers: updatedTrackers,
      updatedAt: DateTime.now(),
    );
    await editGoal(next);
  }

  Future<void> addTracker(GoalModel goal, GoalTracker tracker) async {
    final next = goal.copyWith(
      trackers: [...goal.trackers, tracker],
      updatedAt: DateTime.now(),
    );
    await editGoal(next);
  }

  Future<void> deleteTracker(GoalModel goal, String trackerId) async {
    final updatedTrackers = goal.trackers
        .where((t) => t.id != trackerId)
        .toList();
    final next = goal.copyWith(
      trackers: updatedTrackers,
      updatedAt: DateTime.now(),
    );
    await editGoal(next);
  }

  // ---------------------------------------------------------------------------
  // Daily Tracking Hub & Kanban Board
  // ---------------------------------------------------------------------------
  DateTime selectedDailyDate = DateTime.now();

  void setSelectedDailyDate(DateTime date) {
    selectedDailyDate = date;
    update(['goals', 'daily']);
  }

  List<GoalModel> habitsForDate(DateTime date) {
    return goals.where((g) => g.isHabit && !g.isArchived).toList();
  }

  bool isHabitDoneForDate(GoalModel habit, DateTime date) {
    return habit.checkIns.contains(GoalModel.dateKey(date));
  }

  Future<void> toggleHabitForDate(GoalModel habit, DateTime date) async {
    final key = GoalModel.dateKey(date);
    final nextIns = {...habit.checkIns};
    if (nextIns.contains(key)) {
      nextIns.remove(key);
    } else {
      nextIns.add(key);
    }
    await _saveCheckIns(habit, nextIns);
    update(['goals', 'daily']);
  }

  Future<void> stepTracker(
    GoalModel goal,
    String trackerId,
    bool increment,
  ) async {
    final tracker = goal.trackers.firstWhereOrNull((t) => t.id == trackerId);
    if (tracker == null) return;
    var newVal = tracker.current + (increment ? 1.0 : -1.0);
    if (newVal < 0) newVal = 0;
    if (tracker.target > 0 && newVal > tracker.target) {
      newVal = tracker.target;
    }
    await updateTrackerValue(goal, trackerId, newVal);
    update(['goals', 'daily']);
  }

  DailyTaskGroups dailyTaskGroups(DateTime date, {DateTime? now}) {
    final targetDay = GoalModel.dateOnly(date);
    final today = GoalModel.dateOnly(now ?? DateTime.now());
    final isSelectedToday = targetDay == today;
    final overdue = <GoalTaskEntry>[];
    final scheduled = <GoalTaskEntry>[];
    final anytime = <GoalTaskEntry>[];

    for (final goal in goals) {
      if (goal.isArchived) continue;
      for (final task in goal.tasks) {
        final entry = (goal: goal, task: task);
        final due = task.dueDate;
        if (due == null) {
          if (isSelectedToday) anytime.add(entry);
          continue;
        }
        final taskDay = GoalModel.dateOnly(due);
        if (taskDay == targetDay) {
          scheduled.add(entry);
        } else if (isSelectedToday &&
            taskDay.isBefore(today) &&
            !task.isCompleted) {
          overdue.add(entry);
        }
      }
    }
    overdue.sort((a, b) => a.task.dueDate!.compareTo(b.task.dueDate!));
    return DailyTaskGroups(
      overdue: overdue,
      scheduled: scheduled,
      anytime: anytime,
    );
  }

  List<GoalTaskEntry> tasksForDate(DateTime date) => dailyTaskGroups(date).all;

  ({int completed, int total, double progress}) dailyProgress(DateTime date) {
    final habits = habitsForDate(date);
    final tasks = tasksForDate(date);
    final total = habits.length + tasks.length;
    int completed = 0;

    for (final h in habits) {
      if (isHabitDoneForDate(h, date)) completed++;
    }
    for (final t in tasks) {
      if (t.task.isCompleted) completed++;
    }

    final double prog = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;
    return (completed: completed, total: total, progress: prog);
  }

  static GoalTaskStatus boardColumnOf(GoalModel goal) {
    return switch (goal.status) {
      GoalStatus.notStarted || GoalStatus.archived => GoalTaskStatus.todo,
      GoalStatus.inProgress => GoalTaskStatus.inProgress,
      GoalStatus.pending => GoalTaskStatus.pending,
      GoalStatus.done => GoalTaskStatus.done,
    };
  }

  static GoalStatus goalStatusFor(GoalTaskStatus column) {
    return switch (column) {
      GoalTaskStatus.todo => GoalStatus.notStarted,
      GoalTaskStatus.inProgress => GoalStatus.inProgress,
      GoalTaskStatus.pending => GoalStatus.pending,
      GoalTaskStatus.done => GoalStatus.done,
    };
  }

  List<GoalModel> get archivedGoals =>
      realGoals.where((goal) => goal.isArchived).toList();

  /// Big tasks and standalone inbox tasks grouped into the shared status
  /// columns, filtered by [selectedCategoryId].
  Map<GoalTaskStatus, List<BoardItem>> get boardItems {
    final map = <GoalTaskStatus, List<BoardItem>>{
      for (final s in GoalTaskStatus.values) s: [],
    };
    final section = selectedCategoryId;
    final hasSection = section != null && section.isNotEmpty;

    final bigTasks = realGoals.where((g) => !g.isArchived).toList()
      ..sort((a, b) => a.boardOrder.compareTo(b.boardOrder));
    for (final goal in bigTasks) {
      if (hasSection && goal.category != section) continue;
      map[boardColumnOf(goal)]!.add(GoalBoardItem(goal));
    }

    final inbox = inboxGoal;
    if (inbox != null) {
      for (final task in inbox.tasks) {
        if (hasSection && taskSectionId(inbox, task) != section) continue;
        map[task.status]!.add(TaskBoardItem(inbox, task));
      }
    }
    return map;
  }

  Future<void> moveBoardItem(BoardItem item, GoalTaskStatus column) {
    return switch (item) {
      GoalBoardItem(:final goal) => changeGoalStatus(
        goal,
        goalStatusFor(column),
      ),
      TaskBoardItem(:final goal, :final task) => changeTaskStatus(
        goal,
        task.id,
        column,
      ),
    };
  }

  /// A task's own section, or its goal's section when it has none.
  String? taskSectionId(GoalModel goal, GoalTask task) {
    final own = task.categoryId;
    if (own != null && own.isNotEmpty) return own;
    return goal.isInbox ? null : goal.category;
  }

  Map<GoalTaskStatus, List<({GoalModel goal, GoalTask task})>> tasksByStatus({
    String? filterGoalId,
    String? filterCategoryId,
  }) {
    final map = <GoalTaskStatus, List<({GoalModel goal, GoalTask task})>>{
      for (final s in GoalTaskStatus.values) s: [],
    };

    final targetGoals = (filterGoalId != null && filterGoalId.isNotEmpty)
        ? goals.where((g) => g.id == filterGoalId && !g.isArchived)
        : goals.where((g) => !g.isArchived);
    final hasSectionFilter =
        filterCategoryId != null && filterCategoryId.isNotEmpty;

    for (final goal in targetGoals) {
      for (final task in goal.tasks) {
        if (hasSectionFilter && taskSectionId(goal, task) != filterCategoryId) {
          continue;
        }
        map[task.status]!.add((goal: goal, task: task));
      }
    }

    for (final list in map.values) {
      list.sort((a, b) => a.task.order.compareTo(b.task.order));
    }
    return map;
  }

  Future<void> quickAddTask({
    String? goalId,
    required String title,
    GoalTaskStatus status = GoalTaskStatus.todo,
    AppPriority priority = AppPriority.medium,
    DateTime? dueDate,
    String? dueTime,
    String? assigneeId,
    String? assigneeEmail,
    String? assigneeName,
    String? categoryId,
  }) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) return;

    GoalModel? goal;
    if (goalId != null && goalId.isNotEmpty) {
      goal = goalById(goalId);
    }
    goal ??= await ensureInbox();

    final newTask = GoalTask(
      id: '${DateTime.now().microsecondsSinceEpoch}_${goal.tasks.length}',
      title: cleanTitle,
      status: status,
      priority: priority,
      goalId: goal.id,
      order: goal.tasks.length,
      dueDate: dueDate,
      dueTime: dueTime,
      assigneeId: assigneeId,
      assigneeEmail: assigneeEmail,
      assigneeName: assigneeName,
      categoryId: categoryId,
    );

    final next = goal.copyWith(
      tasks: [...goal.tasks, newTask],
      updatedAt: DateTime.now(),
    );
    await editGoal(next);
    update(['goals', 'daily']);
  }

  // ---------------------------------------------------------------------------
  // Team Collaboration
  // ---------------------------------------------------------------------------

  /// Returns the current user's email (used for invite operations).
  String? get currentUserEmail => Get.find<IAuthService>().currentUser?.email;

  /// Returns the current user's display name.
  String get currentUserName =>
      Get.find<IAuthService>().currentUser?.displayName ?? '';

  /// Returns the members for a specific goal.
  List<GoalMember> goalMembers(String goalId) {
    final goal = goals.firstWhereOrNull((g) => g.id == goalId);
    return goal?.members ?? [];
  }

  /// Whether the current user is the owner of the given goal.
  bool isGoalOwner(String goalId) {
    final goal = goals.firstWhereOrNull((g) => g.id == goalId);
    return goal?.ownerId == ownerId;
  }

  /// Loads pending invites for the current user's email.
  Future<void> loadPendingInvites() async {
    final repo = inviteRepository;
    final email = currentUserEmail;
    if (repo == null || email == null || email.isEmpty) return;
    try {
      pendingInvites = await repo.fetchPendingInvites(email);
      update(['goals']);
    } catch (_) {}
  }

  /// Invites [inviteeEmail] to collaborate on [goalId].
  Future<String?> invitePartner(String goalId, String inviteeEmail) async {
    final repo = inviteRepository;
    if (repo == null) return 'Collaboration not available.';
    final goal = goals.firstWhereOrNull((g) => g.id == goalId);
    if (goal == null) return 'Goal not found.';
    final email = currentUserEmail;
    if (email == null) return 'Not signed in.';

    try {
      await repo.sendInvite(
        goalId: goalId,
        goalTitle: goal.title,
        inviterUid: ownerId,
        inviterEmail: email,
        inviterName: currentUserName,
        inviteeEmail: inviteeEmail.trim().toLowerCase(),
      );
      return null; // success
    } catch (error) {
      return error.toString();
    }
  }

  /// Accepts a pending invite.
  Future<String?> acceptInvite(GoalInvite invite) async {
    final repo = inviteRepository;
    if (repo == null) return 'Collaboration not available.';
    final email = currentUserEmail;
    if (email == null) return 'Not signed in.';

    try {
      await repo.acceptInvite(
        invite: invite,
        acceptorUid: ownerId,
        acceptorEmail: email,
        acceptorName: currentUserName,
      );
      pendingInvites = pendingInvites.where((i) => i.id != invite.id).toList();
      // Reload goals to include the newly joined goal
      await load();
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  /// Declines a pending invite.
  Future<void> declineInvite(GoalInvite invite) async {
    final repo = inviteRepository;
    if (repo == null) return;
    try {
      await repo.declineInvite(invite.id);
      pendingInvites = pendingInvites.where((i) => i.id != invite.id).toList();
      update(['goals']);
    } catch (_) {}
  }

  /// Assigns a task to a team member.
  Future<void> assignTask({
    required GoalModel goal,
    required String taskId,
    GoalMember? member,
  }) async {
    final tasks = goal.tasks.map((t) {
      if (t.id != taskId) return t;
      if (member == null) {
        return t.copyWith(clearAssignee: true);
      }
      return t.copyWith(
        assigneeId: member.uid,
        assigneeEmail: member.email,
        assigneeName: member.displayName,
      );
    }).toList();
    final next = goal.copyWith(tasks: tasks, updatedAt: DateTime.now());
    await editGoal(next);
  }
}
