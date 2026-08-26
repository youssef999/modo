import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/storage_keys.dart';
import 'package:life_daily_app/core/models/app_view_mode.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';
import 'package:life_daily_app/core/utils/week_progress.dart';
import 'package:life_daily_app/features/auth/services/i_auth_service.dart';

import '../models/work_folder.dart';
import '../models/work_item.dart';
import '../repositories/i_work_repository.dart';

class WorkController extends GetxController {
  WorkController(this._repository, this._storage);

  final IWorkRepository _repository;
  final IStorage _storage;

  List<WorkItem> items = [];
  List<WorkFolder> folders = [];
  DateTime day = WorkItem.dateOnly(DateTime.now());
  String? selectedFolderId;
  AppViewMode viewMode = AppViewMode.list;
  bool isLoading = true;
  bool weekSheetRequested = false;

  String get ownerId => Get.find<IAuthService>().currentUser?.uid ?? '';

  String get selectedDayKey => WeekProgress.dayKey(day);

  List<WorkItem> get filteredItems {
    final folderId = selectedFolderId;
    if (folderId == null || folderId.isEmpty) return items;
    return items.where((item) => item.folderId == folderId).toList();
  }

  List<WorkItem> get openItems {
    return filteredItems.where((item) => !item.isDone).toList();
  }

  List<WorkItem> get doneItems {
    return filteredItems.where((item) => item.isDone).toList();
  }

  List<WorkItem> get dayItems {
    return filteredItems.where((item) {
      return WeekProgress.dayKey(item.createdAt) == selectedDayKey ||
          WeekProgress.dayKey(item.updatedAt) == selectedDayKey;
    }).toList();
  }

  int get doneTodayCount {
    return doneItems.where((item) {
      return WeekProgress.dayKey(item.updatedAt) ==
          WeekProgress.dayKey(DateTime.now());
    }).length;
  }

  WeekProgress get week {
    final now = DateTime.now();
    var done = 0;
    var total = 0;
    final active = <String>{};
    for (final item in items) {
      if (WeekProgress.inWeek(item.createdAt, now) ||
          WeekProgress.inWeek(item.updatedAt, now)) {
        total++;
        if (item.isDone) done++;
      }
      active.add(WeekProgress.dayKey(item.createdAt));
      if (item.isDone) {
        active.add(WeekProgress.dayKey(item.updatedAt));
      }
    }
    return WeekProgress(
      done: done,
      total: total,
      streak: WeekProgress.streakDays(active, now),
    );
  }

  List<DateTime> nearbyDays({int count = 7}) {
    final today = WorkItem.dateOnly(DateTime.now());
    return [
      for (var i = 0; i < count; i++) today.add(Duration(days: i)),
    ];
  }

  String folderLabel(WorkFolder folder) {
    if (folder.isBuiltIn) return folder.labelKey.tr;
    return folder.name;
  }

  List<String> folderTitles(String folderId) {
    return items
        .where((item) => item.folderId == folderId)
        .map((item) => item.title)
        .take(3)
        .toList();
  }

  int folderCount(String folderId) {
    return items.where((item) => item.folderId == folderId).length;
  }

  @override
  void onInit() {
    super.onInit();
    _loadViewMode();
    load();
  }

  void _loadViewMode() {
    final saved = _storage.read<String>(StorageKeys.workViewMode);
    viewMode = saved == AppViewMode.grid.name
        ? AppViewMode.grid
        : AppViewMode.list;
  }

  void setViewMode(AppViewMode mode) {
    if (viewMode == mode) return;
    viewMode = mode;
    _storage.write(StorageKeys.workViewMode, mode.name);
    update(['work']);
  }

  bool get isGridView => viewMode == AppViewMode.grid;

  Future<void> load() async {
    isLoading = true;
    update(['work']);
    if (ownerId.isEmpty) {
      isLoading = false;
      update(['work']);
      return;
    }
    folders = await _repository.fetchFolders(ownerId);
    items = await _repository.fetch(ownerId);
    isLoading = false;
    update(['work']);
  }

  Future<void> onAccountReady() async {
    await _repository.syncAfterLogin(ownerId);
    await load();
  }

  void selectDay(DateTime value) {
    day = WorkItem.dateOnly(value);
    update(['work']);
  }

  void selectFolder(String? id) {
    selectedFolderId = id;
    update(['work']);
  }

  void requestWeekSheet() {
    weekSheetRequested = true;
    update(['work']);
  }

  void consumeWeekSheet() {
    weekSheetRequested = false;
  }

  Future<void> add({
    required String title,
    required String details,
    required String folderId,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty || ownerId.isEmpty) return;
    final item = await _repository.create(
      ownerId: ownerId,
      title: trimmed,
      details: details.trim(),
      folderId: folderId,
    );
    items = [item, ...items];
    update(['work']);
  }

  Future<void> edit(WorkItem item) async {
    await _repository.update(item);
    final index = items.indexWhere((entry) => entry.id == item.id);
    if (index == -1) return;
    items[index] = item;
    update(['work']);
  }

  Future<void> toggle(WorkItem item) async {
    final next = item.copyWith(
      status: item.isDone ? WorkStatus.open : WorkStatus.done,
      updatedAt: DateTime.now(),
    );
    await _repository.update(next);
    final index = items.indexWhere((entry) => entry.id == item.id);
    if (index == -1) return;
    items[index] = next;
    update(['work']);
  }

  Future<void> delete(WorkItem item) async {
    await _repository.delete(ownerId, item.id);
    items.removeWhere((entry) => entry.id == item.id);
    update(['work']);
  }

  Future<String?> addFolder(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > 40 || ownerId.isEmpty) {
      return null;
    }
    final folder = await _repository.addFolder(
      ownerId: ownerId,
      name: trimmed,
    );
    folders = [...folders, folder];
    selectedFolderId = folder.id;
    update(['work']);
    return folder.id;
  }

  Future<void> renameFolder(WorkFolder folder, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > 40) return;
    final next = folder.copyWith(name: trimmed);
    await _repository.updateFolder(next);
    final index = folders.indexWhere((item) => item.id == folder.id);
    if (index == -1) return;
    folders[index] = next;
    update(['work']);
  }
}
