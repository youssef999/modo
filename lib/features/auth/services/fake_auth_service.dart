import 'dart:async';

import '../models/app_user.dart';
import 'i_auth_service.dart';

class FakeAuthService implements IAuthService {
  FakeAuthService([AppUser? initialUser])
      : _user = initialUser ??
            const AppUser(
              uid: 'local-dev-uid',
              isAnonymous: false,
              email: 'user@example.com',
            );

  AppUser? _user;
  final _controller = StreamController<AppUser?>.broadcast();

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> get authStateChanges {
    return _controller.stream;
  }

  void _notify() {
    _controller.add(_user);
  }

  @override
  Future<AppUser> ensureAnonymousSession() async {
    _user = const AppUser(uid: 'local-dev-uid', isAnonymous: true);
    return _user!;
  }

  @override
  Future<AppUser> continueWithGoogle() async {
    _user = AppUser(
      uid: _user?.uid ?? 'google-uid',
      isAnonymous: false,
      hasGoogle: true,
      hasApple: _user?.hasApple ?? false,
      hasPassword: _user?.hasPassword ?? false,
      email: 'user@google.com',
      displayName: _user?.displayName,
    );
    return _user!;
  }

  @override
  Future<AppUser> continueWithApple() async {
    _user = AppUser(
      uid: _user?.uid ?? 'apple-uid',
      isAnonymous: false,
      hasGoogle: _user?.hasGoogle ?? false,
      hasApple: true,
      hasPassword: _user?.hasPassword ?? false,
      email: 'user@apple.com',
      displayName: _user?.displayName,
    );
    return _user!;
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    _user = AppUser(
      uid: _user?.uid ?? 'email-uid',
      isAnonymous: false,
      hasGoogle: _user?.hasGoogle ?? false,
      hasApple: _user?.hasApple ?? false,
      hasPassword: true,
      email: email.trim(),
      displayName: _user?.displayName,
    );
    return _user!;
  }

  @override
  Future<AppUser> registerWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    _user = AppUser(
      uid: _user?.uid ?? 'new-uid',
      isAnonymous: false,
      hasGoogle: _user?.hasGoogle ?? false,
      hasApple: _user?.hasApple ?? false,
      hasPassword: true,
      email: email.trim(),
      displayName: displayName ?? _user?.displayName,
    );
    _notify();
    return _user!;
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async {
    _user = null;
    _notify();
  }
}
