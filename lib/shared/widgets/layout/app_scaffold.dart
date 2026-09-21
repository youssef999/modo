import 'package:flutter/material.dart';
import 'package:life_daily_app/core/constants/breakpoints.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_palette.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/shared/widgets/ads/app_banner_ad.dart';
import 'package:life_daily_app/shared/widgets/layout/app_nav_bar.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.bottomBar,
    this.embed = false,
    this.showHeader = true,
    this.showBack = true,
    this.showBanner = true,
    this.onBack,
  });

  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottomBar;
  final bool embed;
  final bool showHeader;
  final bool showBack;
  final bool showBanner;
  final VoidCallback? onBack;

  bool get _usesNavBar => !embed && showHeader && title != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final isDesktop = MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;

    final paddedBody = Padding(
      padding: EdgeInsets.fromLTRB(
        isDesktop ? AppSpacing.xl : AppSpacing.md,
        AppSpacing.sm,
        isDesktop ? AppSpacing.xl : AppSpacing.md,
        (embed && !isDesktop) ? AppSpacing.navClearance : AppSpacing.md,
      ),
      child: body,
    );

    final constrainedBody = isDesktop
        ? Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: paddedBody,
            ),
          )
        : paddedBody;

    final header = embed && showHeader && title != null
        ? Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  0,
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(title!, style: AppTextStyles.h5(colors))),
                    ...?actions,
                  ],
                ),
              ),
            ),
          )
        : const SizedBox.shrink();

    if (embed) {
      return ColoredBox(
        color: colors.background,
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              Expanded(child: constrainedBody),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _usesNavBar
          ? AppNavBar(
              title: title!,
              actions: actions,
              showBack: showBack,
              onBack: onBack,
            )
          : null,
      body: constrainedBody,
      bottomNavigationBar: _BottomChrome(
        colors: colors,
        bottomBar: bottomBar,
        showBanner: showBanner,
      ),
    );
  }
}

class _BottomChrome extends StatelessWidget {
  const _BottomChrome({
    required this.colors,
    required this.bottomBar,
    required this.showBanner,
  });

  final AppPalette colors;
  final Widget? bottomBar;
  final bool showBanner;

  @override
  Widget build(BuildContext context) {
    if (bottomBar == null && !showBanner) return const SizedBox.shrink();
    final isDesktop = MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;
    final constrainedBottomBar = isDesktop && bottomBar != null
        ? Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: bottomBar,
            ),
          )
        : bottomBar;

    return Material(
      color: colors.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (bottomBar != null)
            SafeArea(
              top: false,
              bottom: !showBanner,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: constrainedBottomBar,
              ),
            ),
          if (showBanner) const AppBannerAd(),
        ],
      ),
    );
  }
}
