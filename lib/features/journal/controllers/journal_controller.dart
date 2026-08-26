import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/storage_keys.dart';
import 'package:life_daily_app/core/models/app_view_mode.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';
import 'package:life_daily_app/core/utils/week_progress.dart';
import 'package:life_daily_app/features/auth/services/i_auth_service.dart';

import '../models/journal_entry.dart';
import '../models/journal_folder.dart';
import '../repositories/i_journal_repository.dart';

class JournalController extends GetxController {
  JournalController(this._repository, this._storage);

  final IJournalRepository _repository;
  final IStorage _storage;

  List<JournalEntry> entries = [];
  List<JournalFolder> folders = [];
  DateTime day = JournalEntry.dateOnly(DateTime.now());
  String? selectedFolderId;
  String searchQuery = '';
  AppViewMode viewMode = AppViewMode.list;
  bool isLoading = true;
  bool searchRequested = false;
  bool datePickerRequested = false;
  bool weekSheetRequested = false;

  String get ownerId => Get.find<IAuthService>().currentUser?.uid ?? '';

  String get selectedDayKey => JournalEntry.dayKey(day);

  List<JournalEntry> get scopedEntries {
    final folderId = selectedFolderId;
    if (folderId == null || folderId.isEmpty) return entries;
    return entries.where((entry) => entry.folderId == folderId).toList();
  }

  List<JournalEntry> get dayEntries {
    return scopedEntries.where((entry) => entry.day == selectedDayKey).toList();
  }

  List<JournalEntry> get filteredEntries {
    final query = searchQuery.trim().toLowerCase();
    final source = scopedEntries;
    if (query.isEmpty) return source;
    return source.where((entry) {
      return entry.title.toLowerCase().contains(query) ||
          entry.body.toLowerCase().contains(query);
    }).toList();
  }

  List<JournalEntry> get recentEntries {
    return filteredEntries.take(3).toList();
  }

  Map<String, List<JournalEntry>> get timeline {
    return JournalEntry.groupByDay(filteredEntries);
  }

  WeekProgress get week {
    final now = DateTime.now();
    var notes = 0;
    final active = <String>{};
    for (final entry in entries) {
      active.add(entry.day);
      if (WeekProgress.inWeek(entry.dayDate, now)) notes++;
    }
    return WeekProgress(
      done: notes,
      total: 7,
      streak: WeekProgress.streakDays(active, now),
    );
  }

  List<DateTime> nearbyDays({int count = 7}) {
    final today = JournalEntry.dateOnly(DateTime.now());
    return [
      for (var i = 0; i < count; i++) today.add(Duration(days: i)),
    ];
  }

  String folderLabel(JournalFolder folder) {
    if (folder.isBuiltIn) return folder.labelKey.tr;
    return folder.name;
  }

  List<String> folderTitles(String folderId) {
    return entries
        .where((entry) => entry.folderId == folderId)
        .map((entry) => entry.displayTitle)
        .take(3)
        .toList();
  }

  int folderCount(String folderId) {
    return entries.where((entry) => entry.folderId == folderId).length;
  }

  @override
  void onInit() {
    super.onInit();
    _loadViewMode();
    load();
  }

  void _loadViewMode() {
    final saved = _storage.read<String>(StorageKeys.journalViewMode);
    viewMode = saved == AppViewMode.grid.name
        ? AppViewMode.grid
        : AppViewMode.list;
  }

  void setViewMode(AppViewMode mode) {
    if (viewMode == mode) return;
    viewMode = mode;
    _storage.write(StorageKeys.journalViewMode, mode.name);
    update(['journal']);
  }

  bool get isGridView => viewMode == AppViewMode.grid;

  Future<void> load() async {
    isLoading = true;
    update(['journal']);
    if (ownerId.isEmpty) {
      isLoading = false;
      update(['journal']);
      return;
    }
    folders = await _repository.fetchFolders(ownerId);
    entries = await _repository.fetch(ownerId);
    isLoading = false;
    update(['journal']);
  }

  Future<void> onAccountReady() async {
    await _repository.syncAfterLogin(ownerId);
    await load();
  }

  void selectDay(DateTime value) {
    day = JournalEntry.dateOnly(value);
    update(['journal']);
  }

  void selectFolder(String? id) {
    selectedFolderId = id;
    update(['journal']);
  }

  void setSearch(String value) {
    searchQuery = value;
    update(['journal']);
  }

  void requestSearchFocus() {
    searchRequested = true;
    update(['journal']);
  }

  void consumeSearchFocus() {
    searchRequested = false;
  }

  void requestDatePicker() {
    datePickerRequested = true;
    update(['journal']);
  }

  void consumeDatePicker() {
    datePickerRequested = false;
  }

  void requestWeekSheet() {
    weekSheetRequested = true;
    update(['journal']);
  }

  void consumeWeekSheet() {
    weekSheetRequested = false;
  }

  Future<void> add({
    required String title,
    required String body,
    required String folderId,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty || ownerId.isEmpty) return;
    final entry = await _repository.create(
      ownerId: ownerId,
      title: trimmedTitle,
      body: body.trim(),
      day: selectedDayKey,
      folderId: folderId,
    );
    entries = [entry, ...entries];
    update(['journal']);
  }

  Future<void> edit(JournalEntry entry) async {
    await _repository.update(entry);
    final index = entries.indexWhere((item) => item.id == entry.id);
    if (index == -1) return;
    entries[index] = entry;
    update(['journal']);
  }

  Future<void> delete(JournalEntry entry) async {
    await _repository.delete(ownerId, entry.id);
    entries.removeWhere((item) => item.id == entry.id);
    update(['journal']);
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
    update(['journal']);
    return folder.id;
  }

  Future<void> renameFolder(JournalFolder folder, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > 40) return;
    final next = folder.copyWith(name: trimmed);
    await _repository.updateFolder(next);
    final index = folders.indexWhere((item) => item.id == folder.id);
    if (index == -1) return;
    folders[index] = next;
    update(['journal']);
  }
}
