import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/app_assets.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_gradients.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';

/// The Modo app mark: the ring-and-check logo on its navy tile.
class ModoLogo extends StatelessWidget {
  const ModoLogo({super.key, this.size = AppLogoSize.md, this.glow = true});

  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.28);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: glow
            ? [
                BoxShadow(
                  color: AppColors.brandBlue.withValues(alpha: 0.28),
                  blurRadius: size * 0.35,
                  offset: Offset(0, size * 0.1),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Image.asset(
          AppAssets.modoLogo,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
          semanticLabel: LocaleKeys.appName.tr,
        ),
      ),
    );
  }
}

/// "Modo" painted with the logo's blue → cyan → green gradient.
class ModoWordmark extends StatelessWidget {
  const ModoWordmark({super.key, this.fontSize = AppIconSize.lg});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: AppGradients.brand.createShader,
      child: Text(
        LocaleKeys.appName.tr,
        style: AppTextStyles.wordmark(fontSize),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      ),
    );
  }
}

/// Brand signature: logo, gradient wordmark, signature stroke, and tagline.
class ModoBrandLockup extends StatelessWidget {
  const ModoBrandLockup({
    super.key,
    this.logoSize = AppLogoSize.md,
    this.showTagline = true,
    this.vertical = false,
    this.taglineColor,
  });

  /// Large centered lockup for splash and sign-in.
  const ModoBrandLockup.hero({super.key, this.taglineColor})
    : logoSize = AppLogoSize.xl,
      showTagline = true,
      vertical = true;

  final double logoSize;
  final bool showTagline;
  final bool vertical;
  final Color? taglineColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final wordSize = vertical ? logoSize * 0.42 : logoSize * 0.6;
    final tagline = Text(
      LocaleKeys.brandTagline.tr,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: vertical ? TextAlign.center : TextAlign.start,
      style: AppTextStyles.caption(colors).copyWith(
        color: taglineColor ?? colors.textSecondary,
        fontWeight: FontWeight.w600,
        letterSpacing: vertical ? 1.6 : 0.4,
      ),
    );

    if (vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ModoLogo(size: logoSize),
          const SizedBox(height: AppSpacing.md),
          ModoWordmark(fontSize: wordSize),
          const SizedBox(height: AppSpacing.xs),
          _SignatureStroke(width: wordSize * 1.6),
          if (showTagline) ...[const SizedBox(height: AppSpacing.sm), tagline],
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ModoLogo(size: logoSize, glow: false),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ModoWordmark(fontSize: wordSize),
              if (showTagline) tagline,
            ],
          ),
        ),
      ],
    );
  }
}

class _SignatureStroke extends StatelessWidget {
  const _SignatureStroke({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: AppSpacing.xs,
      decoration: BoxDecoration(
        gradient: AppGradients.brand,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
    );
  }
}
