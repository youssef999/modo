import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/errors/app_failure.dart';
import '../models/app_user.dart';
import 'i_auth_service.dart';

class FirebaseAuthService implements IAuthService {
  FirebaseAuthService({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  bool _googleReady = false;

  @override
  AppUser? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : _map(user);
  }

  @override
  Future<AppUser?> restoreSession() async {
    User? user;
    try {
      user = await _auth.authStateChanges().first.timeout(
        const Duration(seconds: 4),
      );
    } catch (_) {
      user = _auth.currentUser;
    }
    user ??= _auth.currentUser;
    if (user == null) return null;
    try {
      await user.getIdToken();
    } catch (_) {}
    return _map(user);
  }

  @override
  Future<AppUser> ensureAnonymousSession() async {
    final existing = _auth.currentUser;
    if (existing != null) return _map(existing);
    final credential = await _auth.signInAnonymously();
    final user = credential.user;
    if (user == null) {
      throw const AppFailure('Could not start a silent session.');
    }
    return _map(user);
  }

  @override
  Future<AppUser> continueWithGoogle() async {
    if (kIsWeb) return _googleOnWeb();
    final oauth = await _googleCredential();
    return _linkOrSignIn(oauth);
  }

  /// The popup itself signs in (or links the anonymous uid), so the result is
  /// used directly instead of signing in a second time with its credential.
  Future<AppUser> _googleOnWeb() async {
    final provider = GoogleAuthProvider();
    final current = _auth.currentUser;
    try {
      if (current != null && current.isAnonymous) {
        try {
          final linked = await current.linkWithPopup(provider);
          return _map(_requireUser(linked.user));
        } on FirebaseAuthException catch (error) {
          final credential = error.credential;
          if (!_shouldSwitchAccount(error.code) || credential == null) {
            rethrow;
          }
          final result = await _auth.signInWithCredential(credential);
          return _map(_requireUser(result.user));
        }
      }
      final result = await _auth.signInWithPopup(provider);
      return _map(_requireUser(result.user));
    } on FirebaseAuthException catch (error) {
      throw AppFailure(error.message ?? error.code);
    }
  }

  @override
  Future<AppUser> continueWithApple() async {
    final oauth = await _appleCredential();
    return _linkOrSignIn(oauth);
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    final cleanEmail = email.trim();
    final current = _auth.currentUser;

    if (current != null && current.isAnonymous) {
      final credential = EmailAuthProvider.credential(
        email: cleanEmail,
        password: password,
      );
      try {
        final linked = await current.linkWithCredential(credential);
        return _map(_requireUser(linked.user));
      } on FirebaseAuthException catch (error) {
        if (!_shouldSwitchAccount(error.code)) {
          throw AppFailure(error.message ?? error.code);
        }
      }
    }

    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      return _map(_requireUser(result.user));
    } on FirebaseAuthException catch (error) {
      throw AppFailure(error.message ?? error.code);
    }
  }

  @override
  Future<AppUser> registerWithEmail(String email, String password) async {
    final cleanEmail = email.trim();
    final current = _auth.currentUser;

    if (current != null && current.isAnonymous) {
      final credential = EmailAuthProvider.credential(
        email: cleanEmail,
        password: password,
      );
      try {
        final linked = await current.linkWithCredential(credential);
        return _map(_requireUser(linked.user));
      } on FirebaseAuthException catch (error) {
        if (!_shouldSwitchAccount(error.code)) {
          throw AppFailure(error.message ?? error.code);
        }
      }
    }

    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      return _map(_requireUser(result.user));
    } on FirebaseAuthException catch (error) {
      throw AppFailure(error.message ?? error.code);
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    final cleanEmail = email.trim();
    try {
      await _auth.sendPasswordResetEmail(email: cleanEmail);
    } on FirebaseAuthException catch (error) {
      throw AppFailure(error.message ?? error.code);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (error) {
      throw AppFailure(error.message ?? error.code);
    }
  }

  Future<AppUser> _linkOrSignIn(AuthCredential credential) async {
    final current = _auth.currentUser;
    if (current == null) {
      final result = await _auth.signInWithCredential(credential);
      return _map(_requireUser(result.user));
    }

    if (!current.isAnonymous) {
      final result = await _auth.signInWithCredential(credential);
      return _map(_requireUser(result.user));
    }

    try {
      final linked = await current.linkWithCredential(credential);
      return _map(_requireUser(linked.user));
    } on FirebaseAuthException catch (error) {
      if (_shouldSwitchAccount(error.code)) {
        final result = await _auth.signInWithCredential(credential);
        return _map(_requireUser(result.user));
      }
      throw AppFailure(error.message ?? error.code);
    }
  }

  bool _shouldSwitchAccount(String code) {
    return code == 'credential-already-in-use' ||
        code == 'email-already-in-use' ||
        code == 'account-exists-with-different-credential' ||
        code == 'provider-already-linked';
  }

  Future<AuthCredential> _googleCredential() async {
    if (!_googleReady) {
      await GoogleSignIn.instance.initialize();
      _googleReady = true;
    }

    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AppFailure('Google sign-in did not return a token.');
      }
      return GoogleAuthProvider.credential(idToken: idToken);
    } on GoogleSignInException catch (error) {
      throw AppFailure(error.description ?? 'Google sign-in failed.');
    }
  }

  Future<AuthCredential> _appleCredential() async {
    final rawNonce = _randomNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();
    final apple = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );
    final idToken = apple.identityToken;
    if (idToken == null) {
      throw const AppFailure('Apple sign-in did not return a token.');
    }
    return OAuthProvider(
      'apple.com',
    ).credential(idToken: idToken, rawNonce: rawNonce);
  }

  User _requireUser(User? user) {
    if (user == null) {
      throw const AppFailure('Sign-in did not complete.');
    }
    return user;
  }

  AppUser _map(User user) {
    final providers = user.providerData.map((item) => item.providerId).toSet();
    return AppUser(
      uid: user.uid,
      isAnonymous: user.isAnonymous,
      hasGoogle: providers.contains('google.com'),
      hasApple: providers.contains('apple.com'),
      hasPassword: providers.contains('password'),
      email: user.email,
      displayName: user.displayName,
    );
  }

  String _randomNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }
}
