import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_gradients.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/auth/controllers/profile_controller.dart';
import 'package:life_daily_app/features/home/widgets/name_intro_dialog.dart';

class HomeWelcomeBanner extends StatelessWidget {
  const HomeWelcomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GetBuilder<ProfileController>(
      id: 'profile',
      builder: (profile) {
        final title = profile.hasName
            ? LocaleKeys.helloName.trParams({'name': profile.displayName})
            : LocaleKeys.helloGuest.tr;
        return Material(
          color: colors.card.withValues(alpha: 0),
          child: InkWell(
            onTap: profile.hasName
                ? null
                : () => NameIntroDialog.showIfNeeded(force: true),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryHero(colors),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -AppSpacing.xl,
                      top: -AppSpacing.lg,
                      child: _Glow(
                        size: AppSpacing.xxl * 2,
                        color: colors.onPrimary,
                      ),
                    ),
                    Positioned(
                      left: -AppSpacing.md,
                      bottom: -AppSpacing.lg,
                      child: _Glow(
                        size: AppSpacing.xxl,
                        color: colors.secondaryLight,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.xl,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocaleKeys.appName.tr,
                            style: AppTextStyles.caption(colors).copyWith(
                              color: colors.onPrimary.withValues(alpha: 0.78),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            title,
                            style: AppTextStyles.h2(
                              colors,
                            ).copyWith(color: colors.onPrimary),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            LocaleKeys.homePromo.tr,
                            style: AppTextStyles.body2(colors).copyWith(
                              color: colors.onPrimary.withValues(alpha: 0.9),
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.16),
        ),
      ),
    );
  }
}
