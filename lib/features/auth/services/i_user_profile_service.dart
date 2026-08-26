import '../../auth/models/app_user.dart';

abstract class IUserProfileService {
  Future<void> ensureProfile(AppUser user);

  Future<String?> readDisplayName(String uid);

  Future<void> saveDisplayName(String uid, String name);
}
