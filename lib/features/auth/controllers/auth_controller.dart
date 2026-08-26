import 'package:get/get.dart';
import 'package:life_daily_app/core/ads/interstitial_ad_service.dart';
import 'package:life_daily_app/core/errors/app_failure.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/journal/controllers/journal_controller.dart';
import 'package:life_daily_app/features/work/controllers/work_controller.dart';

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

  Future<void> continueWithGoogle() => _link(
        _auth.continueWithGoogle,
        showAd: true,
      );

  Future<void> continueWithApple() => _link(_auth.continueWithApple);

  Future<void> _link(
    Future<AppUser> Function() action, {
    bool showAd = false,
  }) async {
    if (isBusy) return;
    isBusy = true;
    errorMessage = null;
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
      if (Get.isRegistered<JournalController>()) {
        await Get.find<JournalController>().onAccountReady();
      }
      if (Get.isRegistered<WorkController>()) {
        await Get.find<WorkController>().onAccountReady();
      }
      if (showAd && Get.isRegistered<InterstitialAdService>()) {
        await Get.find<InterstitialAdService>().showIfReady();
      }
    } catch (error) {
      errorMessage = _message(error);
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
