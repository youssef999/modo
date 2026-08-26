import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_daily_app/core/constants/firestore_paths.dart';

import '../models/journal_entry.dart';
import '../models/journal_folder.dart';
import 'i_journal_repository.dart';

class FirestoreJournalRepository implements IJournalRepository {
  FirestoreJournalRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String ownerId) {
    return _db.collection(FirestorePaths.userJournal(ownerId));
  }

  CollectionReference<Map<String, dynamic>> _folders(String ownerId) {
    return _db.collection(FirestorePaths.userJournalFolders(ownerId));
  }

  @override
  Future<List<JournalFolder>> fetchFolders(String ownerId) async {
    final snapshot = await _folders(ownerId).get();
    var items = snapshot.docs.map(_folderFromDoc).toList();
    items = JournalFolder.withGeneral(ownerId, items);
    await saveAllFolders(items);
    return items;
  }

  @override
  Future<JournalFolder> addFolder({
    required String ownerId,
    required String name,
  }) async {
    final now = DateTime.now();
    final ref = _folders(ownerId).doc();
    final folder = JournalFolder(
      id: ref.id,
      ownerId: ownerId,
      name: name.trim(),
      builtInKey: '',
      createdAt: now,
      updatedAt: now,
    );
    await saveFolder(folder);
    return folder;
  }

  @override
  Future<void> updateFolder(JournalFolder folder) {
    return saveFolder(folder.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> saveFolder(JournalFolder folder) {
    return _folders(
      folder.ownerId,
    ).doc(folder.id).set(_folderToFirestore(folder));
  }

  Future<void> saveAllFolders(List<JournalFolder> items) async {
    if (items.isEmpty) return;
    var batch = _db.batch();
    var count = 0;
    for (final item in items) {
      batch.set(_folders(item.ownerId).doc(item.id), _folderToFirestore(item));
      count++;
      if (count == 450) {
        await batch.commit();
        batch = _db.batch();
        count = 0;
      }
    }
    if (count > 0) await batch.commit();
  }

  @override
  Future<List<JournalEntry>> fetch(String ownerId) async {
    final snapshot = await _col(ownerId).get();
    final items = snapshot.docs.map(_fromDoc).toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
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
    final ref = _col(ownerId).doc();
    final entry = JournalEntry(
      id: ref.id,
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
    return save(entry);
  }

  Future<void> save(JournalEntry entry) {
    return _col(entry.ownerId).doc(entry.id).set(_toFirestore(entry));
  }

  Future<void> saveAll(List<JournalEntry> items) async {
    if (items.isEmpty) return;
    var batch = _db.batch();
    var count = 0;
    for (final item in items) {
      batch.set(_col(item.ownerId).doc(item.id), _toFirestore(item));
      count++;
      if (count == 450) {
        await batch.commit();
        batch = _db.batch();
        count = 0;
      }
    }
    if (count > 0) await batch.commit();
  }

  @override
  Future<void> delete(String ownerId, String id) {
    return _col(ownerId).doc(id).delete();
  }

  @override
  Future<void> syncAfterLogin(String ownerId) async {}

  Map<String, dynamic> _toFirestore(JournalEntry entry) {
    return {
      'ownerId': entry.ownerId,
      'title': entry.title,
      'body': entry.body,
      'day': entry.day,
      'folderId': entry.folderId,
      'createdAt': Timestamp.fromDate(entry.createdAt),
      'updatedAt': Timestamp.fromDate(entry.updatedAt),
    };
  }

  JournalEntry _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdAt = _date(data['createdAt']);
    final body = data['body'] as String? ?? '';
    final rawTitle = (data['title'] as String? ?? '').trim();
    return JournalEntry(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      title: rawTitle.isNotEmpty ? rawTitle : JournalEntry.titleFromBody(body),
      body: body,
      day: (data['day'] as String?)?.trim().isNotEmpty == true
          ? data['day'] as String
          : JournalEntry.dayKey(createdAt),
      folderId: (data['folderId'] as String?)?.trim().isNotEmpty == true
          ? data['folderId'] as String
          : JournalFolder.generalId,
      createdAt: createdAt,
      updatedAt: _date(data['updatedAt']),
    );
  }

  Map<String, dynamic> _folderToFirestore(JournalFolder folder) {
    return {
      'ownerId': folder.ownerId,
      'name': folder.name,
      'builtInKey': folder.builtInKey,
      'createdAt': Timestamp.fromDate(folder.createdAt),
      'updatedAt': Timestamp.fromDate(folder.updatedAt),
    };
  }

  JournalFolder _folderFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return JournalFolder(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      builtInKey: data['builtInKey'] as String? ?? '',
      createdAt: _date(data['createdAt']),
      updatedAt: _date(data['updatedAt']),
    );
  }

  DateTime _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
