import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_gradients.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return AppCard(
      gradient: AppGradients.primaryHero(colors),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.appName.tr,
            style: AppTextStyles.caption(
              colors,
            ).copyWith(color: colors.onPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            LocaleKeys.homeTitle.tr,
            style: AppTextStyles.h3(colors).copyWith(color: colors.onPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            LocaleKeys.homeSubtitle.tr,
            style: AppTextStyles.body2(
              colors,
            ).copyWith(color: colors.onPrimary.withValues(alpha: 0.86)),
          ),
        ],
      ),
    );
  }
}
