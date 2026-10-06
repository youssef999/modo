import 'package:life_daily_app/features/auth/models/app_user.dart';
import 'package:life_daily_app/features/auth/services/i_auth_service.dart';

/// Controllable fake auth service for unit tests.
class FakeAuthService implements IAuthService {
  AppUser? user;
  AppUser? nextUser; // returned by sign-in methods

  @override
  AppUser? get currentUser => user;

  @override
  Future<AppUser?> restoreSession() async => currentUser;

  @override
  Future<AppUser> ensureAnonymousSession() async {
    user = const AppUser(uid: 'anon-uid', isAnonymous: true);
    return user!;
  }

  @override
  Future<AppUser> continueWithGoogle() async {
    user =
        nextUser ??
        const AppUser(
          uid: 'google-uid',
          isAnonymous: false,
          email: 'user@google.com',
        );
    nextUser = null;
    return user!;
  }

  @override
  Future<AppUser> continueWithApple() async {
    user =
        nextUser ??
        const AppUser(
          uid: 'apple-uid',
          isAnonymous: false,
          email: 'user@apple.com',
        );
    nextUser = null;
    return user!;
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    user =
        nextUser ??
        AppUser(
          uid: 'email-uid',
          isAnonymous: false,
          email: email,
          hasPassword: true,
        );
    nextUser = null;
    return user!;
  }

  @override
  Future<AppUser> registerWithEmail(String email, String password) async {
    user =
        nextUser ??
        AppUser(
          uid: 'new-uid',
          isAnonymous: false,
          email: email,
          hasPassword: true,
        );
    nextUser = null;
    return user!;
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async {
    user = null;
  }
}
