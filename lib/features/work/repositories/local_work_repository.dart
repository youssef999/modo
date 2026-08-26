import 'dart:convert';
import 'dart:math';

import 'package:life_daily_app/core/constants/storage_keys.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';

import '../models/work_folder.dart';
import '../models/work_item.dart';
import 'i_work_repository.dart';

class LocalWorkRepository implements IWorkRepository {
  LocalWorkRepository(this._storage);

  final IStorage _storage;
  final _random = Random();

  @override
  Future<List<WorkItem>> fetch(String ownerId) async {
    var items = _read();
    if (ownerId.isNotEmpty && items.any((item) => item.ownerId != ownerId)) {
      items = [
        for (final item in items)
          item.ownerId == ownerId ? item : item.copyWith(ownerId: ownerId),
      ];
      await replaceAll(items);
    }
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<List<WorkFolder>> fetchFolders(String ownerId) async {
    var items = _readFolders();
    if (ownerId.isNotEmpty && items.any((item) => item.ownerId != ownerId)) {
      items = [
        for (final item in items)
          item.ownerId == ownerId ? item : item.copyWith(ownerId: ownerId),
      ];
      await replaceFolders(items);
    }
    items = WorkFolder.withGeneral(ownerId, items);
    await replaceFolders(items);
    return items;
  }

  @override
  Future<WorkFolder> addFolder({
    required String ownerId,
    required String name,
  }) async {
    final now = DateTime.now();
    final folder = WorkFolder(
      id: '${now.microsecondsSinceEpoch}${_random.nextInt(999)}',
      ownerId: ownerId,
      name: name.trim(),
      builtInKey: '',
      createdAt: now,
      updatedAt: now,
    );
    final items = await fetchFolders(ownerId);
    await replaceFolders([...items, folder]);
    return folder;
  }

  @override
  Future<void> updateFolder(WorkFolder folder) async {
    final items = _readFolders();
    final index = items.indexWhere((item) => item.id == folder.id);
    if (index == -1) {
      items.add(folder);
    } else {
      items[index] = folder.copyWith(updatedAt: DateTime.now());
    }
    await replaceFolders(items);
  }

  @override
  Future<WorkItem> create({
    required String ownerId,
    required String title,
    required String details,
    required String folderId,
  }) async {
    final now = DateTime.now();
    final item = WorkItem(
      id: '${now.microsecondsSinceEpoch}${_random.nextInt(999)}',
      ownerId: ownerId,
      title: title.trim(),
      details: details.trim(),
      folderId: folderId,
      status: WorkStatus.open,
      createdAt: now,
      updatedAt: now,
    );
    await save(item);
    return item;
  }

  @override
  Future<void> update(WorkItem item) {
    return save(item.copyWith(updatedAt: DateTime.now()));
  }

  @override
  Future<void> delete(String ownerId, String id) async {
    final items = _read()
      ..removeWhere((item) => item.id == id && item.ownerId == ownerId);
    await replaceAll(items);
  }

  @override
  Future<void> syncAfterLogin(String ownerId) async {
    await fetch(ownerId);
  }

  Future<void> save(WorkItem item) async {
    final items = _read();
    final index = items.indexWhere((entry) => entry.id == item.id);
    if (index == -1) {
      items.add(item);
    } else {
      items[index] = item;
    }
    await replaceAll(items);
  }

  Future<void> replaceAll(List<WorkItem> items) {
    final payload = items
        .map((item) => {'id': item.id, ...item.toMap()})
        .toList();
    return _storage.write(StorageKeys.workCache, jsonEncode(payload));
  }

  Future<void> replaceFolders(List<WorkFolder> items) {
    final payload = items
        .map((item) => {'id': item.id, ...item.toMap()})
        .toList();
    return _storage.write(StorageKeys.workFolders, jsonEncode(payload));
  }

  List<WorkFolder> _readFolders() {
    final raw = _storage.read<String>(StorageKeys.workFolders);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (item) => WorkFolder.fromMap(
              item['id'] as String,
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<WorkItem> _read() {
    final raw = _storage.read<String>(StorageKeys.workCache);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (item) => WorkItem.fromMap(
              item['id'] as String,
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }
}
