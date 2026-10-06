import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/storage_keys.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';
import 'package:life_daily_app/features/auth/services/i_auth_service.dart';
import 'package:life_daily_app/features/auth/services/i_user_profile_service.dart';

class ProfileController extends GetxController {
  ProfileController(this._storage, this._auth, this._profiles);

  final IStorage _storage;
  final IAuthService _auth;
  final IUserProfileService _profiles;

  String displayName = '';
  bool isSaving = false;
  bool isSynced = false;

  bool get hasName => displayName.trim().isNotEmpty;

  String? get email {
    final value = _auth.currentUser?.email?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  /// Signed in, profile loaded from the server, and no name stored yet.
  bool get needsName {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return false;
    return isSynced && !hasName;
  }

  @override
  void onInit() {
    super.onInit();
    displayName = _storage.read<String>(StorageKeys.displayName) ?? '';
  }

  Future<void> syncFromRemote() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      await clear();
      return;
    }
    final remote = await _profiles.readDisplayName(uid);
    displayName = remote?.trim() ?? '';
    isSynced = true;
    if (displayName.isEmpty) {
      await _storage.remove(StorageKeys.displayName);
    } else {
      await _storage.write(StorageKeys.displayName, displayName);
    }
    update(['profile']);
  }

  Future<void> clear() async {
    displayName = '';
    isSynced = false;
    await _storage.remove(StorageKeys.displayName);
    update(['profile']);
  }

  Future<void> saveName(String value) async {
    final name = value.trim();
    if (name.isEmpty || isSaving || hasName) return;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    isSaving = true;
    update(['profile']);
    try {
      final claimed = await _profiles.claimDisplayName(uid, name);
      if (claimed) {
        displayName = name;
        await _storage.write(StorageKeys.displayName, name);
      } else {
        await syncFromRemote();
      }
    } finally {
      isSaving = false;
      update(['profile']);
    }
  }
}
