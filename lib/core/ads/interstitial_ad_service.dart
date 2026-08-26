import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:life_daily_app/core/ads/ad_config.dart';
import 'package:life_daily_app/core/ads/admob_bootstrap.dart';

/// Preloads and shows interstitial ads for key actions.
class InterstitialAdService extends GetxService {
  InterstitialAd? _ad;
  bool _loading = false;
  bool _showing = false;

  Future<InterstitialAdService> init() async {
    await preload();
    return this;
  }

  Future<void> preload() async {
    if (!AdConfig.isSupported || !AdMobBootstrap.isReady) return;
    if (_loading || _ad != null) return;
    _loading = true;
    await InterstitialAd.load(
      adUnitId: AdConfig.interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loading = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (dismissed) {
              dismissed.dispose();
              _ad = null;
              _showing = false;
              preload();
            },
            onAdFailedToShowFullScreenContent: (failed, error) {
              debugPrint('Interstitial show failed: ${error.message}');
              failed.dispose();
              _ad = null;
              _showing = false;
              preload();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial load failed: ${error.message}');
          _loading = false;
          _ad = null;
        },
      ),
    );
  }

  /// Shows a ready interstitial, or no-ops quietly if unavailable.
  Future<void> showIfReady() async {
    if (!AdConfig.isSupported || !AdMobBootstrap.isReady) return;
    if (_showing) return;
    final ad = _ad;
    if (ad == null) {
      await preload();
      return;
    }
    _showing = true;
    _ad = null;
    await ad.show();
  }
}
