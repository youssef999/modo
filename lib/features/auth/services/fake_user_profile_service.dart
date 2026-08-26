import '../../auth/models/app_user.dart';
import 'i_user_profile_service.dart';

class FakeUserProfileService implements IUserProfileService {
  final Map<String, String> _names = {};

  @override
  Future<void> ensureProfile(AppUser user) async {}

  @override
  Future<String?> readDisplayName(String uid) async => _names[uid];

  @override
  Future<void> saveDisplayName(String uid, String name) async {
    _names[uid] = name;
  }
}
