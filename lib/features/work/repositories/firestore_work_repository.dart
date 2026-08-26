import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_daily_app/core/constants/firestore_paths.dart';

import '../models/work_folder.dart';
import '../models/work_item.dart';
import 'i_work_repository.dart';

class FirestoreWorkRepository implements IWorkRepository {
  FirestoreWorkRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String ownerId) {
    return _db.collection(FirestorePaths.userWork(ownerId));
  }

  CollectionReference<Map<String, dynamic>> _folders(String ownerId) {
    return _db.collection(FirestorePaths.userWorkFolders(ownerId));
  }

  @override
  Future<List<WorkFolder>> fetchFolders(String ownerId) async {
    final snapshot = await _folders(ownerId).get();
    var items = snapshot.docs.map(_folderFromDoc).toList();
    items = WorkFolder.withGeneral(ownerId, items);
    await saveAllFolders(items);
    return items;
  }

  @override
  Future<WorkFolder> addFolder({
    required String ownerId,
    required String name,
  }) async {
    final now = DateTime.now();
    final ref = _folders(ownerId).doc();
    final folder = WorkFolder(
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
  Future<void> updateFolder(WorkFolder folder) {
    return saveFolder(folder.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> saveFolder(WorkFolder folder) {
    return _folders(folder.ownerId).doc(folder.id).set(_folderToFirestore(folder));
  }

  Future<void> saveAllFolders(List<WorkFolder> items) async {
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
  Future<List<WorkItem>> fetch(String ownerId) async {
    final snapshot = await _col(ownerId).get();
    final items = snapshot.docs.map(_fromDoc).toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<WorkItem> create({
    required String ownerId,
    required String title,
    required String details,
    required String folderId,
  }) async {
    final now = DateTime.now();
    final ref = _col(ownerId).doc();
    final item = WorkItem(
      id: ref.id,
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
    return save(item);
  }

  Future<void> save(WorkItem item) {
    return _col(item.ownerId).doc(item.id).set(_toFirestore(item));
  }

  Future<void> saveAll(List<WorkItem> items) async {
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

  Map<String, dynamic> _toFirestore(WorkItem item) {
    return {
      'ownerId': item.ownerId,
      'title': item.title,
      'details': item.details,
      'folderId': item.folderId,
      'status': item.status.name,
      'createdAt': Timestamp.fromDate(item.createdAt),
      'updatedAt': Timestamp.fromDate(item.updatedAt),
    };
  }

  WorkItem _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return WorkItem(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      details: data['details'] as String? ?? '',
      folderId: (data['folderId'] as String?)?.trim().isNotEmpty == true
          ? data['folderId'] as String
          : WorkFolder.generalId,
      status: (data['status'] as String?) == WorkStatus.done.name
          ? WorkStatus.done
          : WorkStatus.open,
      createdAt: _date(data['createdAt']),
      updatedAt: _date(data['updatedAt']),
    );
  }

  Map<String, dynamic> _folderToFirestore(WorkFolder folder) {
    return {
      'ownerId': folder.ownerId,
      'name': folder.name,
      'builtInKey': folder.builtInKey,
      'createdAt': Timestamp.fromDate(folder.createdAt),
      'updatedAt': Timestamp.fromDate(folder.updatedAt),
    };
  }

  WorkFolder _folderFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return WorkFolder(
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
