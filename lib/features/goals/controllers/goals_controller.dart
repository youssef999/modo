import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/constants/storage_keys.dart';
import 'package:life_daily_app/core/models/app_view_mode.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';
import 'package:life_daily_app/features/auth/services/i_auth_service.dart';

import '../models/goal_category.dart';
import '../models/goal_model.dart';
import '../repositories/i_goal_repository.dart';

class GoalsController extends GetxController {
  GoalsController(this._repository, this._storage);

  final IGoalRepository _repository;
  final IStorage _storage;

  List<GoalModel> goals = [];
  List<GoalCategory> categories = [];
  String? selectedCategoryId;
  AppViewMode viewMode = AppViewMode.list;
  bool isLoading = true;

  String get ownerId => Get.find<IAuthService>().currentUser?.uid ?? '';

  List<GoalModel> get scopedGoals {
    final folderId = selectedCategoryId;
    if (folderId == null || folderId.isEmpty) return goals;
    return goals.where((goal) => goal.category == folderId).toList();
  }

  List<GoalModel> get visibleGoals => scopedGoals;

  List<GoalModel> get activeGoals {
    return scopedGoals.where((goal) => !goal.isFullyComplete).toList();
  }

  List<GoalModel> get doneGoals {
    return scopedGoals.where((goal) => goal.isFullyComplete).toList();
  }

  int get doneCount => goals.where((goal) => goal.isFullyComplete).length;

  int get totalCount => goals.length;

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
  }) async {
    final goal = await _repository.create(
      ownerId: ownerId,
      title: title.trim(),
      details: details.trim(),
      kind: kind,
      startsAt: startsAt,
      dueAt: dueAt,
      category: category,
    );
    goals = [...goals, goal]..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    update(['goals']);
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

  Future<void> toggleDone(GoalModel goal) async {
    if (goal.isHabit) return;
    final next = goal.copyWith(
      status: goal.isDone ? GoalStatus.active : GoalStatus.done,
      updatedAt: DateTime.now(),
    );
    await editGoal(next);
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
      next.copyWith(status: complete ? GoalStatus.done : GoalStatus.active),
    );
  }
}
