import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:life_daily_app/core/ads/ad_config.dart';
import 'package:life_daily_app/core/ads/admob_bootstrap.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';

/// Small AdMob banner for page bottoms.
class AppBannerAd extends StatefulWidget {
  const AppBannerAd({super.key, this.includeSafeArea = true});

  final bool includeSafeArea;

  @override
  State<AppBannerAd> createState() => _AppBannerAdState();
}

class _AppBannerAdState extends State<AppBannerAd> {
  BannerAd? _banner;
  bool _loaded = false;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadIfNeeded();
  }

  Future<void> _loadIfNeeded() async {
    if (_loading || _banner != null) return;
    if (!AdConfig.isSupported || !AdMobBootstrap.isReady) return;
    _loading = true;
    final ad = BannerAd(
      size: AdSize.banner,
      adUnitId: AdConfig.bannerUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (loaded) {
          if (!mounted) {
            loaded.dispose();
            return;
          }
          setState(() {
            _banner = loaded as BannerAd;
            _loaded = true;
          });
        },
        onAdFailedToLoad: (failed, error) {
          failed.dispose();
          debugPrint('Banner failed: ${error.message}');
          _loading = false;
          if (mounted) {
            setState(() {
              _banner = null;
              _loaded = false;
            });
          }
        },
      ),
    );
    await ad.load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdConfig.isSupported) return const SizedBox.shrink();
    final colors = context.appPalette;
    final banner = _banner;
    final child = !_loaded || banner == null
        ? const SizedBox(
            width: double.infinity,
            height: AdConfig.bannerHeight,
          )
        : SizedBox(
            width: double.infinity,
            height: banner.size.height.toDouble(),
            child: Center(
              child: SizedBox(
                width: banner.size.width.toDouble(),
                height: banner.size.height.toDouble(),
                child: AdWidget(ad: banner),
              ),
            ),
          );

    return ColoredBox(
      color: colors.background,
      child: widget.includeSafeArea
          ? SafeArea(top: false, child: child)
          : child,
    );
  }
}
