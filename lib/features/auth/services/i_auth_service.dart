import '../models/app_user.dart';

abstract class IAuthService {
  AppUser? get currentUser;

  Future<AppUser> ensureAnonymousSession();

  Future<AppUser> continueWithGoogle();

  Future<AppUser> continueWithApple();
}
