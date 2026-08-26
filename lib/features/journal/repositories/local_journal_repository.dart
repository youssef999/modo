import 'dart:convert';
import 'dart:math';

import 'package:life_daily_app/core/constants/storage_keys.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';

import '../models/journal_entry.dart';
import '../models/journal_folder.dart';
import 'i_journal_repository.dart';

class LocalJournalRepository implements IJournalRepository {
  LocalJournalRepository(this._storage);

  final IStorage _storage;
  final _random = Random();

  @override
  Future<List<JournalEntry>> fetch(String ownerId) async {
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
  Future<List<JournalFolder>> fetchFolders(String ownerId) async {
    var items = _readFolders();
    if (ownerId.isNotEmpty && items.any((item) => item.ownerId != ownerId)) {
      items = [
        for (final item in items)
          item.ownerId == ownerId ? item : item.copyWith(ownerId: ownerId),
      ];
      await replaceFolders(items);
    }
    items = JournalFolder.withGeneral(ownerId, items);
    await replaceFolders(items);
    return items;
  }

  @override
  Future<JournalFolder> addFolder({
    required String ownerId,
    required String name,
  }) async {
    final now = DateTime.now();
    final folder = JournalFolder(
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
  Future<void> updateFolder(JournalFolder folder) async {
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
  Future<JournalEntry> create({
    required String ownerId,
    required String title,
    required String body,
    required String day,
    required String folderId,
  }) async {
    final now = DateTime.now();
    final entry = JournalEntry(
      id: '${now.microsecondsSinceEpoch}${_random.nextInt(999)}',
      ownerId: ownerId,
      title: title.trim(),
      body: body.trim(),
      day: day,
      folderId: folderId,
      createdAt: now,
      updatedAt: now,
    );
    await save(entry);
    return entry;
  }

  @override
  Future<void> update(JournalEntry entry) {
    return save(entry.copyWith(updatedAt: DateTime.now()));
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

  Future<void> save(JournalEntry entry) async {
    final items = _read();
    final index = items.indexWhere((item) => item.id == entry.id);
    if (index == -1) {
      items.add(entry);
    } else {
      items[index] = entry;
    }
    await replaceAll(items);
  }

  Future<void> replaceAll(List<JournalEntry> items) {
    final payload = items
        .map((item) => {'id': item.id, ...item.toMap()})
        .toList();
    return _storage.write(StorageKeys.journalCache, jsonEncode(payload));
  }

  Future<void> replaceFolders(List<JournalFolder> items) {
    final payload = items
        .map((item) => {'id': item.id, ...item.toMap()})
        .toList();
    return _storage.write(StorageKeys.journalFolders, jsonEncode(payload));
  }

  List<JournalFolder> _readFolders() {
    final raw = _storage.read<String>(StorageKeys.journalFolders);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (item) => JournalFolder.fromMap(
              item['id'] as String,
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<JournalEntry> _read() {
    final raw = _storage.read<String>(StorageKeys.journalCache);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (item) => JournalEntry.fromMap(
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
