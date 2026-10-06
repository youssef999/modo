import 'package:life_daily_app/features/auth/models/app_user.dart';
import 'package:life_daily_app/features/auth/services/i_user_profile_service.dart';

class FakeUserProfileService implements IUserProfileService {
  final Map<String, String> _names = {};

  @override
  Future<void> ensureProfile(AppUser user) async {}

  @override
  Future<String?> readDisplayName(String uid) async => _names[uid];

  @override
  Future<bool> claimDisplayName(String uid, String name) async {
    if ((_names[uid] ?? '').isNotEmpty) return false;
    _names[uid] = name;
    return true;
  }
}
