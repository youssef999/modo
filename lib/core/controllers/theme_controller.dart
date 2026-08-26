import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/ads/interstitial_ad_service.dart';

import '../constants/storage_keys.dart';
import '../storage/i_storage.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../theme/app_theme_id.dart';

class ThemeController extends GetxController {
  ThemeController(this._storage);

  final IStorage _storage;

  AppThemeId themeId = AppThemeId.light;

  ThemeData get themeData => AppTheme.forId(themeId);

  AppPalette get palette => AppColors.forId(themeId);

  bool get isDark => themeId.isDark;

  @override
  void onInit() {
    super.onInit();
    _restore();
  }

  void setTheme(AppThemeId id) {
    if (themeId == id) return;
    themeId = id;
    Get.changeTheme(AppTheme.forId(id));
    _storage.write(StorageKeys.appThemeId, id.name);
    update(['theme']);
    _showThemeAd();
  }

  void cycleTheme() {
    final index = AppThemeId.values.indexOf(themeId);
    final next = AppThemeId.values[(index + 1) % AppThemeId.values.length];
    setTheme(next);
  }

  void _showThemeAd() {
    if (!Get.isRegistered<InterstitialAdService>()) return;
    Get.find<InterstitialAdService>().showIfReady();
  }

  void _restore() {
    final saved = _storage.read<String>(StorageKeys.appThemeId);
    if (saved != null) {
      themeId = AppThemeId.fromStorage(saved);
    } else {
      final legacy = _storage.read<String>(StorageKeys.themeMode);
      themeId = legacy == 'dark' ? AppThemeId.dark : AppThemeId.light;
    }
    Get.changeTheme(AppTheme.forId(themeId));
  }
}
