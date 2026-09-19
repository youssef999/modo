import '../models/app_user.dart';

abstract class IAuthService {
  AppUser? get currentUser;

  Future<AppUser> ensureAnonymousSession();

  Future<AppUser> continueWithGoogle();

  Future<AppUser> continueWithApple();

  Future<AppUser> signInWithEmail(String email, String password);

  Future<AppUser> registerWithEmail(String email, String password);

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();
}
