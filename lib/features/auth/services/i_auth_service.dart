import '../models/app_user.dart';

abstract class IAuthService {
  AppUser? get currentUser;

  Stream<AppUser?> get authStateChanges;

  Future<AppUser> ensureAnonymousSession();

  Future<AppUser> continueWithGoogle();

  Future<AppUser> continueWithApple();

  Future<AppUser> signInWithEmail(String email, String password);

  Future<AppUser> registerWithEmail(
    String email,
    String password, {
    String? displayName,
  });

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();
}
