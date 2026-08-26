import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/controllers/locale_controller.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';
import 'package:life_daily_app/shared/widgets/layout/app_theme_picker.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';

class HomeSettingsCard extends StatelessWidget {
  const HomeSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                size: AppIconSize.md,
                color: colors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(LocaleKeys.theme.tr, style: AppTextStyles.h6(colors)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const AppThemePicker(),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Icon(
                Icons.translate,
                size: AppIconSize.md,
                color: colors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(LocaleKeys.language.tr, style: AppTextStyles.h6(colors)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          GetBuilder<LocaleController>(
            builder: (controller) {
              return Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: LocaleKeys.english.tr,
                      variant: controller.isArabic
                          ? AppButtonVariant.secondary
                          : AppButtonVariant.primary,
                      onPressed: () =>
                          controller.setLocale(const Locale('en', 'US')),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton(
                      label: LocaleKeys.arabic.tr,
                      variant: controller.isArabic
                          ? AppButtonVariant.primary
                          : AppButtonVariant.secondary,
                      onPressed: () =>
                          controller.setLocale(const Locale('ar', 'SA')),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
