import '../models/journal_entry.dart';
import '../models/journal_folder.dart';
import 'firestore_journal_repository.dart';
import 'i_journal_repository.dart';
import 'local_journal_repository.dart';

class CachedJournalRepository implements IJournalRepository {
  CachedJournalRepository({
    required this.local,
    this.remote,
    required this.isCloudEnabled,
  });

  final LocalJournalRepository local;
  final FirestoreJournalRepository? remote;
  final bool Function() isCloudEnabled;

  bool get _useCloud => remote != null && isCloudEnabled();

  @override
  Future<List<JournalFolder>> fetchFolders(String ownerId) async {
    var items = await local.fetchFolders(ownerId);
    if (_useCloud) {
      try {
        items = JournalFolder.withGeneral(ownerId, items);
        await remote!.saveAllFolders(items);
        items = await remote!.fetchFolders(ownerId);
        items = JournalFolder.withGeneral(ownerId, items);
        await remote!.saveAllFolders(items);
        await local.replaceFolders(items);
      } catch (_) {}
    }
    return items;
  }

  @override
  Future<JournalFolder> addFolder({
    required String ownerId,
    required String name,
  }) async {
    final folder = await local.addFolder(ownerId: ownerId, name: name);
    await _tryCloud(() => remote!.saveFolder(folder));
    return folder;
  }

  @override
  Future<void> updateFolder(JournalFolder folder) async {
    await local.updateFolder(folder);
    await _tryCloud(() => remote!.saveFolder(folder));
  }

  @override
  Future<List<JournalEntry>> fetch(String ownerId) async {
    final localItems = await local.fetch(ownerId);
    if (_useCloud) {
      return _fetchFromCloud(ownerId, localItems);
    }
    if (localItems.isEmpty) {
      return _hydrateFromAnonymousCloud(ownerId);
    }
    return localItems;
  }

  @override
  Future<JournalEntry> create({
    required String ownerId,
    required String title,
    required String body,
    required String day,
    required String folderId,
  }) async {
    final entry = await local.create(
      ownerId: ownerId,
      title: title,
      body: body,
      day: day,
      folderId: folderId,
    );
    await _tryCloud(() => remote!.save(entry));
    return entry;
  }

  @override
  Future<void> update(JournalEntry entry) async {
    await local.update(entry);
    await _tryCloud(() => remote!.save(entry));
  }

  @override
  Future<void> delete(String ownerId, String id) async {
    await local.delete(ownerId, id);
    await _tryCloud(() => remote!.delete(ownerId, id));
  }

  @override
  Future<void> syncAfterLogin(String ownerId) async {
    final folders = await local.fetchFolders(ownerId);
    final localItems = await local.fetch(ownerId);
    if (!_useCloud) return;
    await _tryCloud(() => remote!.saveAllFolders(folders));
    await _tryCloud(() => remote!.saveAll(localItems));
    try {
      await local.replaceFolders(await remote!.fetchFolders(ownerId));
      await local.replaceAll(await remote!.fetch(ownerId));
    } catch (_) {}
  }

  Future<List<JournalEntry>> _fetchFromCloud(
    String ownerId,
    List<JournalEntry> localItems,
  ) async {
    try {
      await remote!.saveAll(localItems);
      final remoteItems = await remote!.fetch(ownerId);
      await local.replaceAll(remoteItems);
      return remoteItems;
    } catch (_) {
      return localItems;
    }
  }

  Future<List<JournalEntry>> _hydrateFromAnonymousCloud(String ownerId) async {
    final cloud = remote;
    if (cloud == null || ownerId.isEmpty) return const [];
    try {
      final remoteItems = await cloud.fetch(ownerId);
      if (remoteItems.isEmpty) return const [];
      await local.replaceAll(remoteItems);
      return remoteItems;
    } catch (_) {
      return const [];
    }
  }

  Future<void> _tryCloud(Future<void> Function() action) async {
    if (!_useCloud) return;
    try {
      await action();
    } catch (_) {}
  }
}
