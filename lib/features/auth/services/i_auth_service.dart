import '../models/app_user.dart';

abstract class IAuthService {
  AppUser? get currentUser;

  /// Waits until the persisted session is restored and its ID token is ready,
  /// so the first Firestore read after sign-in runs as that user.
  Future<AppUser?> restoreSession();

  Future<AppUser> ensureAnonymousSession();

  Future<AppUser> continueWithGoogle();

  Future<AppUser> continueWithApple();

  Future<AppUser> signInWithEmail(String email, String password);

  Future<AppUser> registerWithEmail(String email, String password);

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();
}
