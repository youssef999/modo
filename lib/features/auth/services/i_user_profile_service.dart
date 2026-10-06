import '../../auth/models/app_user.dart';

abstract class IUserProfileService {
  Future<void> ensureProfile(AppUser user);

  Future<String?> readDisplayName(String uid);

  /// Writes [name] only if the account has no name yet.
  /// Returns false when a name was already stored.
  Future<bool> claimDisplayName(String uid, String name);
}
