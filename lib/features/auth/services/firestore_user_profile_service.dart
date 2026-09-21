import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../auth/models/app_user.dart';
import 'i_user_profile_service.dart';

class FirestoreUserProfileService implements IUserProfileService {
  FirestoreUserProfileService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Future<void> ensureProfile(AppUser user) async {
    final ref = _db.doc(FirestorePaths.userDoc(user.uid));
    final snapshot = await ref.get();
    final now = FieldValue.serverTimestamp();
    final providers = <String>[
      if (user.hasGoogle) 'google.com',
      if (user.hasApple) 'apple.com',
      if (user.isAnonymous) 'anonymous',
    ];

    if (!snapshot.exists) {
      await ref.set({
        'createdAt': now,
        'updatedAt': now,
        'isAnonymous': user.isAnonymous,
        'linkedProviders': providers,
        'schemaVersion': 1,
        'displayName': user.displayName ?? '',
      });
      return;
    }

    final currentName = snapshot.data()?['displayName'] as String? ?? '';
    final resolvedName =
        currentName.isNotEmpty ? currentName : (user.displayName ?? '');
    await ref.update({
      'updatedAt': now,
      'isAnonymous': user.isAnonymous,
      'linkedProviders': providers,
      'displayName': resolvedName,
    });
  }

  @override
  Future<String?> readDisplayName(String uid) async {
    final snapshot = await _db.doc(FirestorePaths.userDoc(uid)).get();
    final name = snapshot.data()?['displayName'] as String?;
    if (name == null || name.trim().isEmpty) return null;
    return name.trim();
  }

  @override
  Future<void> saveDisplayName(String uid, String name) async {
    await _db.doc(FirestorePaths.userDoc(uid)).set({
      'displayName': name.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
