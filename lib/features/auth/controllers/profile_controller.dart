import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/storage_keys.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';
import 'package:life_daily_app/features/auth/controllers/auth_controller.dart';
import 'package:life_daily_app/features/auth/services/i_user_profile_service.dart';

class ProfileController extends GetxController {
  ProfileController(this._storage, this._profiles);

  final IStorage _storage;
  final IUserProfileService _profiles;

  String displayName = '';
  bool isSaving = false;
  bool _introShown = false;

  bool get hasName => displayName.trim().isNotEmpty;

  bool get introShown => _introShown;

  void markIntroShown() {
    _introShown = true;
  }

  @override
  void onInit() {
    super.onInit();
    displayName = _storage.read<String>(StorageKeys.displayName) ?? '';
  }

  Future<void> syncFromRemote() async {
    final uid = Get.find<AuthController>().user?.uid;
    if (uid == null) return;
    final remote = await _profiles.readDisplayName(uid);
    if (remote == null || remote.isEmpty) return;
    displayName = remote;
    await _storage.write(StorageKeys.displayName, remote);
    update(['profile']);
  }

  Future<void> saveName(String value) async {
    final name = value.trim();
    if (name.isEmpty || isSaving) return;
    isSaving = true;
    update(['profile']);
    displayName = name;
    await _storage.write(StorageKeys.displayName, name);
    final uid = Get.find<AuthController>().user?.uid;
    if (uid != null) {
      await _profiles.saveDisplayName(uid, name);
    }
    isSaving = false;
    update(['profile']);
  }
}
