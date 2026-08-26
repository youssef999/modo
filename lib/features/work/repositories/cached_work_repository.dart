import '../models/work_folder.dart';
import '../models/work_item.dart';
import 'firestore_work_repository.dart';
import 'i_work_repository.dart';
import 'local_work_repository.dart';

class CachedWorkRepository implements IWorkRepository {
  CachedWorkRepository({
    required this.local,
    this.remote,
    required this.isCloudEnabled,
  });

  final LocalWorkRepository local;
  final FirestoreWorkRepository? remote;
  final bool Function() isCloudEnabled;

  bool get _useCloud => remote != null && isCloudEnabled();

  @override
  Future<List<WorkFolder>> fetchFolders(String ownerId) async {
    var items = await local.fetchFolders(ownerId);
    if (_useCloud) {
      try {
        items = WorkFolder.withGeneral(ownerId, items);
        await remote!.saveAllFolders(items);
        items = await remote!.fetchFolders(ownerId);
        items = WorkFolder.withGeneral(ownerId, items);
        await remote!.saveAllFolders(items);
        await local.replaceFolders(items);
      } catch (_) {}
    }
    return items;
  }

  @override
  Future<WorkFolder> addFolder({
    required String ownerId,
    required String name,
  }) async {
    final folder = await local.addFolder(ownerId: ownerId, name: name);
    await _tryCloud(() => remote!.saveFolder(folder));
    return folder;
  }

  @override
  Future<void> updateFolder(WorkFolder folder) async {
    await local.updateFolder(folder);
    await _tryCloud(() => remote!.saveFolder(folder));
  }

  @override
  Future<List<WorkItem>> fetch(String ownerId) async {
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
  Future<WorkItem> create({
    required String ownerId,
    required String title,
    required String details,
    required String folderId,
  }) async {
    final item = await local.create(
      ownerId: ownerId,
      title: title,
      details: details,
      folderId: folderId,
    );
    await _tryCloud(() => remote!.save(item));
    return item;
  }

  @override
  Future<void> update(WorkItem item) async {
    await local.update(item);
    await _tryCloud(() => remote!.save(item));
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

  Future<List<WorkItem>> _fetchFromCloud(
    String ownerId,
    List<WorkItem> localItems,
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

  Future<List<WorkItem>> _hydrateFromAnonymousCloud(String ownerId) async {
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
