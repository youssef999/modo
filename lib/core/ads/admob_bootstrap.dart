import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:life_daily_app/core/ads/ad_config.dart';
import 'package:life_daily_app/core/ads/interstitial_ad_service.dart';

class AdMobBootstrap {
  AdMobBootstrap._();

  static bool _ready = false;

  static bool get isReady => _ready;

  static Future<void> init() async {
    if (!AdConfig.isSupported) {
      _ready = false;
      return;
    }
    try {
      await MobileAds.instance.initialize();
      _ready = true;
      if (!Get.isRegistered<InterstitialAdService>()) {
        Get.put(InterstitialAdService(), permanent: true);
      }
      await Get.find<InterstitialAdService>().init();
    } catch (error, stack) {
      _ready = false;
      debugPrint('AdMob init failed: $error\n$stack');
    }
  }
}
