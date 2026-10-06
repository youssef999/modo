import 'package:get/get.dart';
import 'package:life_daily_app/core/ads/interstitial_ad_service.dart';
import 'package:life_daily_app/core/errors/app_failure.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';

import '../models/app_user.dart';
import 'profile_controller.dart';
import '../services/i_auth_service.dart';
import '../services/i_user_profile_service.dart';

class AuthController extends GetxController {
  AuthController(this._auth, this._profiles);

  final IAuthService _auth;
  final IUserProfileService _profiles;

  AppUser? user;
  bool isBusy = false;
  bool isBootstrapping = true;
  String? errorMessage;
  String? infoMessage;

  @override
  void onInit() {
    super.onInit();
    user ??= _auth.currentUser;
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
      final existing = await _auth.restoreSession();
      if (existing != null && !existing.isAnonymous) {
        user = existing;
        await _profiles.ensureProfile(user!);
        isBootstrapping = false;
        update(['auth']);
        return true;
      }
      // No logged-in user — require login
      user = null;
      await _clearProfile();
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

  Future<bool> continueWithGoogle() =>
      _executeAuth(_auth.continueWithGoogle, showAd: true);

  Future<bool> continueWithApple() => _executeAuth(_auth.continueWithApple);

  Future<bool> signInWithEmail(String email, String password) {
    return _executeAuth(
      () => _auth.signInWithEmail(email, password),
      showAd: true,
    );
  }

  Future<bool> registerWithEmail(String email, String password) {
    return _executeAuth(
      () => _auth.registerWithEmail(email, password),
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

  /// Returns true once the session is closed and in-memory data is cleared.
  Future<bool> signOut() async {
    if (isBusy) return false;
    isBusy = true;
    errorMessage = null;
    infoMessage = null;
    update(['auth']);
    try {
      await _auth.signOut();
      user = null;
      await _clearProfile();
      _clearAccountData();
      return true;
    } catch (error) {
      errorMessage = _message(error);
      return false;
    } finally {
      isBusy = false;
      update(['auth']);
    }
  }

  void _clearAccountData() {
    if (Get.isRegistered<GoalsController>()) {
      Get.find<GoalsController>().clearAccountData();
    }
    if (Get.isRegistered<FinanceController>()) {
      Get.find<FinanceController>().clearAccountData();
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
      user = await _auth.restoreSession() ?? user;
      await _profiles.ensureProfile(user!);
      await _onSignedIn(syncData: true);
      update(['auth']);
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

  /// Reloads the signed-in account's data into the live controllers.
  /// The shell calls this on open because controllers created on the login
  /// route are disposed when that route is replaced.
  Future<void> refreshAccountData() async {
    if (!isLoggedIn) return;
    await _onSignedIn(syncData: false);
  }

  /// Single place that refreshes everything tied to the signed-in account,
  /// so every sign-in path updates the UI without a manual refresh.
  Future<void> _onSignedIn({required bool syncData}) async {
    await Future.wait([
      if (Get.isRegistered<ProfileController>())
        Get.find<ProfileController>().syncFromRemote(),
      if (Get.isRegistered<GoalsController>())
        syncData
            ? Get.find<GoalsController>().onAccountReady()
            : Get.find<GoalsController>().load(),
      if (Get.isRegistered<FinanceController>())
        syncData
            ? Get.find<FinanceController>().onAccountReady()
            : Get.find<FinanceController>().load(),
    ]);
  }

  Future<void> _clearProfile() async {
    if (Get.isRegistered<ProfileController>()) {
      await Get.find<ProfileController>().clear();
    }
  }

  String _message(Object error) {
    if (error is AppFailure) return error.message;
    return error.toString();
  }
}
