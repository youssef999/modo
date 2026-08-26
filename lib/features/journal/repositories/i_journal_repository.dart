import '../models/journal_entry.dart';
import '../models/journal_folder.dart';

abstract class IJournalRepository {
  Future<List<JournalFolder>> fetchFolders(String ownerId);

  Future<JournalFolder> addFolder({
    required String ownerId,
    required String name,
  });

  Future<void> updateFolder(JournalFolder folder);

  Future<List<JournalEntry>> fetch(String ownerId);

  Future<JournalEntry> create({
    required String ownerId,
    required String title,
    required String body,
    required String day,
    required String folderId,
  });

  Future<void> update(JournalEntry entry);

  Future<void> delete(String ownerId, String id);

  Future<void> syncAfterLogin(String ownerId);
}
