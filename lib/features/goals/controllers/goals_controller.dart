import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/constants/storage_keys.dart';
import 'package:life_daily_app/core/errors/app_failure.dart';
import 'package:life_daily_app/core/models/app_priority.dart';
import 'package:life_daily_app/core/models/app_view_mode.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';
import 'package:life_daily_app/features/auth/services/i_auth_service.dart';

import '../models/goal_category.dart';
import '../models/goal_invite.dart';
import '../models/goal_member.dart';
import '../models/goal_model.dart';
import '../models/goal_task.dart';
import '../models/goal_tracker.dart';
import '../repositories/i_goal_invite_repository.dart';
import '../repositories/i_goal_repository.dart';

class GoalsController extends GetxController {
  GoalsController(
    this._repository,
    this._storage, {
    this.inviteRepository,
  });

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

  void clearFilters() {
    selectedCategoryId = null;
    statusFilter = null;
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

  List<GoalModel> get scopedGoals {
    final folderId = selectedCategoryId;
    if (folderId == null || folderId.isEmpty) return goals;
    return goals.where((goal) => goal.category == folderId).toList();
  }

  List<GoalModel> get visibleGoals => filteredGoals;

  List<GoalModel> get activeGoals {
    return scopedGoals.where((goal) => goal.isActive).toList();
  }

  List<GoalModel> get doneGoals {
    return scopedGoals.where((goal) => goal.isDone || goal.isArchived).toList();
  }

  int get doneCount => doneGoals.length;

  int get totalCount => goals.length;

  int statusCount(GoalStatus status) {
    return scopedGoals.where((g) => g.status == status).length;
  }

  double get progress {
    if (goals.isEmpty) return 0;
    final sum = goals.fold<double>(0, (value, goal) => value + goal.progress);
    return sum / goals.length;
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
    viewMode = saved == AppViewMode.grid.name
        ? AppViewMode.grid
        : AppViewMode.list;
  }

  void setViewMode(AppViewMode mode) {
    if (viewMode == mode) return;
    viewMode = mode;
    _storage.write(StorageKeys.goalsViewMode, mode.name);
    update(['goals']);
  }

  bool get isGridView => viewMode == AppViewMode.grid;

  Future<void> load() async {
    isLoading = true;
    update(['goals']);
    if (ownerId.isEmpty) {
      isLoading = false;
      update(['goals']);
      return;
    }
    categories = await _repository.fetchCategories(ownerId);
    goals = await _repository.fetch(ownerId);
    isLoading = false;
    update(['goals']);
    // Load pending invites in the background (non-blocking)
    loadPendingInvites();
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
    return goals.where((goal) => goal.category == folderId).length;
  }

  List<String> folderTitles(String folderId) {
    return goals
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

  Future<String?> addCategory(String name, {String iconKey = 'star'}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;
    final category = await _repository.addCategory(
      ownerId: ownerId,
      name: trimmed,
      iconKey: iconKey,
    );
    categories = [...categories, category];
    selectedCategoryId = category.id;
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
  }

  Future<void> changeGoalPriority(GoalModel goal, AppPriority newPriority) async {
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
  }

  Future<void> deleteGoal(GoalModel goal) async {
    await _repository.delete(ownerId, goal.id);
    goals = goals.where((item) => item.id != goal.id).toList();
    update(['goals']);
  }

  Future<void> changeGoalStatus(GoalModel goal, GoalStatus newStatus) async {
    if (goal.status == newStatus) return;
    final next = goal.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );
    await editGoal(next);
  }

  Future<void> reorderGoal(GoalModel goal, int newOrder) async {
    final next = goal.copyWith(
      boardOrder: newOrder,
      updatedAt: DateTime.now(),
    );
    await editGoal(next);
  }

  Future<void> changeTaskStatus(GoalModel goal, String taskId, GoalTaskStatus newStatus) async {
    final updatedTasks = goal.tasks.map((task) {
      if (task.id == taskId) {
        return task.copyWith(status: newStatus);
      }
      return task;
    }).toList();
    final next = goal.copyWith(
      tasks: updatedTasks,
      updatedAt: DateTime.now(),
    );
    await editGoal(next);
  }

  Future<void> changeTaskPriority(GoalModel goal, String taskId, AppPriority newPriority) async {
    final updatedTasks = goal.tasks.map((task) {
      if (task.id == taskId) {
        return task.copyWith(priority: newPriority);
      }
      return task;
    }).toList();
    final next = goal.copyWith(
      tasks: updatedTasks,
      updatedAt: DateTime.now(),
    );
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
    final updatedFromTasks = fromGoal.tasks.where((t) => t.id != taskId).toList();
    final updatedFromGoal = fromGoal.copyWith(
      tasks: updatedFromTasks,
      updatedAt: DateTime.now(),
    );
    await editGoal(updatedFromGoal);

    // Add to target goal
    final updatedToGoal = toGoal.copyWith(
      tasks: [...toGoal.tasks, taskToMove.copyWith(order: toGoal.tasks.length)],
      updatedAt: DateTime.now(),
    );
    await editGoal(updatedToGoal);
  }

  Future<void> toggleDone(GoalModel goal) async {
    if (goal.isHabit) return;
    await changeGoalStatus(goal, goal.isDone ? GoalStatus.notStarted : GoalStatus.done);
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

  Future<void> toggleTask(GoalModel goal, String taskId) async {
    final updatedTasks = goal.tasks.map((task) {
      if (task.id == taskId) {
        return task.copyWith(
            status: task.isCompleted ? GoalTaskStatus.todo : GoalTaskStatus.done);
      }
      return task;
    }).toList();
    final next = goal.copyWith(
      tasks: updatedTasks,
      updatedAt: DateTime.now(),
    );
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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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
    final next = goal.copyWith(
      tasks: updatedTasks,
      updatedAt: DateTime.now(),
    );
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
          currentMilestoneIndex: milestoneIndex ?? tracker.currentMilestoneIndex,
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
    final updatedTrackers =
        goal.trackers.where((t) => t.id != trackerId).toList();
    final next = goal.copyWith(
      trackers: updatedTrackers,
      updatedAt: DateTime.now(),
    );
    await editGoal(next);
  }

  // ---------------------------------------------------------------------------
  // Team Collaboration
  // ---------------------------------------------------------------------------

  /// Returns the current user's email (used for invite operations).
  String? get currentUserEmail =>
      Get.find<IAuthService>().currentUser?.email;

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
      // Ensure goal document is saved to top-level and user collections
      await _repository.update(goal);

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
      if (error is AppFailure) return error.message;
      return error.toString();
    }
  }

  /// Fetches pending outgoing invites for a goal.
  Future<List<GoalInvite>> loadGoalPendingInvites(String goalId) async {
    final repo = inviteRepository;
    if (repo == null) return [];
    try {
      return await repo.fetchGoalPendingInvites(goalId);
    } catch (_) {
      return [];
    }
  }

  /// Cancels an outgoing pending invite.
  Future<String?> cancelGoalInvite(String inviteId) async {
    final repo = inviteRepository;
    if (repo == null) return 'Collaboration not available.';
    try {
      await repo.cancelInvite(inviteId);
      return null;
    } catch (error) {
      if (error is AppFailure) return error.message;
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
      pendingInvites =
          pendingInvites.where((i) => i.id != invite.id).toList();
      update(['goals']);
      // Reload goals to include the newly joined goal
      await load();
      return null;
    } catch (error) {
      if (error is AppFailure) return error.message;
      return error.toString();
    }
  }

  /// Declines a pending invite.
  Future<void> declineInvite(GoalInvite invite) async {
    final repo = inviteRepository;
    if (repo == null) return;
    try {
      await repo.declineInvite(invite.id);
      pendingInvites =
          pendingInvites.where((i) => i.id != invite.id).toList();
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
