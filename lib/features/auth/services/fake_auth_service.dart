import '../models/app_user.dart';
import 'i_auth_service.dart';

class FakeAuthService implements IAuthService {
  AppUser _user = const AppUser(uid: 'local-dev-uid', isAnonymous: true);

  @override
  AppUser? get currentUser => _user;

  @override
  Future<AppUser> ensureAnonymousSession() async => _user;

  @override
  Future<AppUser> continueWithGoogle() async {
    _user = AppUser(
      uid: _user.uid,
      isAnonymous: false,
      hasGoogle: true,
      hasApple: _user.hasApple,
      displayName: _user.displayName,
    );
    return _user;
  }

  @override
  Future<AppUser> continueWithApple() async {
    _user = AppUser(
      uid: _user.uid,
      isAnonymous: false,
      hasGoogle: _user.hasGoogle,
      hasApple: true,
      displayName: _user.displayName,
    );
    return _user;
  }
}
