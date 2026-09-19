import 'package:get/get.dart';
import 'package:life_daily_app/core/ads/interstitial_ad_service.dart';
import 'package:life_daily_app/core/errors/app_failure.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';

import '../models/app_user.dart';
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

  bool get isBackedUp => user?.isBackedUp ?? false;

  Future<bool> bootstrap() async {
    isBootstrapping = true;
    errorMessage = null;
    update(['auth']);
    try {
      user = await _auth.ensureAnonymousSession();
      await _profiles.ensureProfile(user!);
      isBootstrapping = false;
      update(['auth']);
      return true;
    } catch (error) {
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

  Future<void> signOut() async {
    if (isBusy) return;
    isBusy = true;
    errorMessage = null;
    infoMessage = null;
    update(['auth']);
    try {
      await _auth.signOut();
      user = _auth.currentUser;
      if (user != null) {
        await _profiles.ensureProfile(user!);
      }
      if (Get.isRegistered<GoalsController>()) {
        await Get.find<GoalsController>().load();
      }
      if (Get.isRegistered<FinanceController>()) {
        await Get.find<FinanceController>().load();
      }
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
