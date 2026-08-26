import 'dart:io';

import 'package:flutter/foundation.dart';

/// AdMob IDs. Replace production values before store release.
///
/// Override with:
/// `--dart-define=ADMOB_ANDROID_APP_ID=...`
/// `--dart-define=ADMOB_IOS_APP_ID=...`
/// `--dart-define=ADMOB_ANDROID_BANNER_ID=...`
/// `--dart-define=ADMOB_IOS_BANNER_ID=...`
class AdConfig {
  AdConfig._();

  static const _androidAppId = String.fromEnvironment(
    'ADMOB_ANDROID_APP_ID',
    defaultValue: 'ca-app-pub-3940256099942544~3347511713',
  );
  static const _iosAppId = String.fromEnvironment(
    'ADMOB_IOS_APP_ID',
    defaultValue: 'ca-app-pub-3940256099942544~1458002511',
  );
  static const _androidBannerId = String.fromEnvironment(
    'ADMOB_ANDROID_BANNER_ID',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111',
  );
  static const _iosBannerId = String.fromEnvironment(
    'ADMOB_IOS_BANNER_ID',
    defaultValue: 'ca-app-pub-3940256099942544/2934735716',
  );

  static const _androidInterstitialId = String.fromEnvironment(
    'ADMOB_ANDROID_INTERSTITIAL_ID',
    defaultValue: 'ca-app-pub-3940256099942544/1033173712',
  );
  static const _iosInterstitialId = String.fromEnvironment(
    'ADMOB_IOS_INTERSTITIAL_ID',
    defaultValue: 'ca-app-pub-3940256099942544/4411468910',
  );

  static bool get isSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  static String get appId {
    if (Platform.isIOS) return _iosAppId;
    return _androidAppId;
  }

  static String get bannerUnitId {
    if (Platform.isIOS) return _iosBannerId;
    return _androidBannerId;
  }

  static String get interstitialUnitId {
    if (Platform.isIOS) return _iosInterstitialId;
    return _androidInterstitialId;
  }

  /// Standard small banner height (points).
  static const double bannerHeight = 50;
}
