import '../models/work_folder.dart';
import '../models/work_item.dart';

abstract class IWorkRepository {
  Future<List<WorkFolder>> fetchFolders(String ownerId);

  Future<WorkFolder> addFolder({required String ownerId, required String name});

  Future<void> updateFolder(WorkFolder folder);

  Future<List<WorkItem>> fetch(String ownerId);

  Future<WorkItem> create({
    required String ownerId,
    required String title,
    required String details,
    required String folderId,
  });

  Future<void> update(WorkItem item);

  Future<void> delete(String ownerId, String id);

  Future<void> syncAfterLogin(String ownerId);
}
