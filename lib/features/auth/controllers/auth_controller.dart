import 'dart:async';

import 'package:get/get.dart';
import 'package:life_daily_app/core/ads/interstitial_ad_service.dart';
import 'package:life_daily_app/core/errors/app_failure.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';

import '../models/app_user.dart';
import '../services/i_auth_service.dart';
import '../services/i_user_profile_service.dart';
import 'profile_controller.dart';

class AuthController extends GetxController {
  AuthController(this._auth, this._profiles);

  final IAuthService _auth;
  final IUserProfileService _profiles;

  AppUser? user;
  bool isBusy = false;
  bool isBootstrapping = true;
  String? errorMessage;
  String? infoMessage;
  StreamSubscription<AppUser?>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    final existing = _auth.currentUser;
    if (existing != null && !existing.isAnonymous) {
      user = existing;
    }
    _authSubscription = _auth.authStateChanges.listen((newUser) async {
      if (newUser != null && !newUser.isAnonymous) {
        final previousUid = user?.uid;
        user = newUser;
        update(['auth']);
        if (previousUid != newUser.uid) {
          try {
            await _profiles.ensureProfile(newUser);
          } catch (_) {}
          if (Get.isRegistered<ProfileController>()) {
            await Get.find<ProfileController>().syncFromRemote();
          }
          if (Get.isRegistered<GoalsController>()) {
            await Get.find<GoalsController>().onAccountReady();
          }
          if (Get.isRegistered<FinanceController>()) {
            await Get.find<FinanceController>().onAccountReady();
          }
        }
      } else if (newUser == null && user != null) {
        user = null;
        update(['auth']);
        if (Get.isRegistered<GoalsController>()) {
          Get.find<GoalsController>().load();
        }
        if (Get.isRegistered<FinanceController>()) {
          Get.find<FinanceController>().load();
        }
      }
    });
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  bool get isBackedUp => user?.isBackedUp ?? false;

  /// True only when the user is fully authenticated (not anonymous, not null).
  bool get isLoggedIn {
    final u = user;
    return u != null && !u.isAnonymous;
  }

  /// Checks if there is an existing signed-in session.
  /// Returns true if a logged-in user exists, false if login is required.
  Future<bool> bootstrap() async {
    isBootstrapping = true;
    errorMessage = null;
    update(['auth']);
    try {
      final existing = _auth.currentUser;
      if (existing != null && !existing.isAnonymous) {
        user = existing;
        await _profiles.ensureProfile(user!);
        if (Get.isRegistered<ProfileController>()) {
          await Get.find<ProfileController>().syncFromRemote();
        }
        isBootstrapping = false;
        update(['auth']);
        return true;
      }
      // No logged-in user — require login
      user = null;
      isBootstrapping = false;
      update(['auth']);
      return false;
    } catch (error) {
      user = null;
      isBootstrapping = false;
      errorMessage = _message(error);
      update(['auth']);
      return false;
    }
  }

  Future<bool> continueWithGoogle() => _executeAuth(
        _auth.continueWithGoogle,
        showAd: true,
      );

  Future<bool> continueWithApple() => _executeAuth(_auth.continueWithApple);

  Future<bool> signInWithEmail(String email, String password) {
    return _executeAuth(
      () => _auth.signInWithEmail(email, password),
      showAd: true,
    );
  }

  Future<bool> registerWithEmail(
    String email,
    String password, {
    String? displayName,
  }) {
    return _executeAuth(
      () async {
        final res = await _auth.registerWithEmail(
          email,
          password,
          displayName: displayName,
        );
        if (displayName != null && displayName.trim().isNotEmpty) {
          if (Get.isRegistered<ProfileController>()) {
            await Get.find<ProfileController>().saveName(displayName.trim());
          }
        }
        return res;
      },
      showAd: true,
    );
  }

  Future<bool> sendPasswordReset(String email) async {
    if (isBusy) return false;
    isBusy = true;
    errorMessage = null;
    infoMessage = null;
    update(['auth']);
    try {
      await _auth.sendPasswordReset(email);
      infoMessage = 'Password reset instructions sent.';
      return true;
    } catch (error) {
      errorMessage = _message(error);
      return false;
    } finally {
      isBusy = false;
      update(['auth']);
    }
  }

  Future<void> signOut() async {
    if (isBusy) return;
    isBusy = true;
    errorMessage = null;
    infoMessage = null;
    update(['auth']);
    try {
      await _auth.signOut();
      user = null;
    } catch (error) {
      errorMessage = _message(error);
    } finally {
      isBusy = false;
      update(['auth']);
    }
  }

  Future<bool> _executeAuth(
    Future<AppUser> Function() action, {
    bool showAd = false,
  }) async {
    if (isBusy) return false;
    isBusy = true;
    errorMessage = null;
    infoMessage = null;
    update(['auth']);
    try {
      user = await action();
      await _profiles.ensureProfile(user!);
      if (Get.isRegistered<ProfileController>()) {
        await Get.find<ProfileController>().syncFromRemote();
      }
      if (Get.isRegistered<GoalsController>()) {
        await Get.find<GoalsController>().onAccountReady();
      }
      if (Get.isRegistered<FinanceController>()) {
        await Get.find<FinanceController>().onAccountReady();
      }
      if (showAd && Get.isRegistered<InterstitialAdService>()) {
        await Get.find<InterstitialAdService>().showIfReady();
      }
      return true;
    } catch (error) {
      errorMessage = _message(error);
      return false;
    } finally {
      isBusy = false;
      update(['auth']);
    }
  }

  String _message(Object error) {
    if (error is AppFailure) return error.message;
    return error.toString();
  }
}
