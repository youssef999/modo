import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/auth/controllers/auth_controller.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';

class SaveDataCard extends StatelessWidget {
  const SaveDataCard({super.key});

  bool get _showApple {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GetBuilder<AuthController>(
      id: 'auth',
      builder: (controller) {
        if (controller.isBackedUp) {
          return AppCard(
            child: Row(
              children: [
                Icon(
                  Icons.cloud_done_outlined,
                  size: AppIconSize.lg,
                  color: colors.success,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    LocaleKeys.dataSaved.tr,
                    style: AppTextStyles.body1(colors),
                  ),
                ),
              ],
            ),
          );
        }

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                LocaleKeys.saveDataTitle.tr,
                style: AppTextStyles.h6(colors),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                LocaleKeys.saveDataSubtitle.tr,
                style: AppTextStyles.body2(colors),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: LocaleKeys.continueGoogle.tr,
                onPressed: controller.isBusy
                    ? null
                    : controller.continueWithGoogle,
              ),
              if (_showApple) ...[
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: LocaleKeys.continueApple.tr,
                  variant: AppButtonVariant.secondary,
                  onPressed: controller.isBusy
                      ? null
                      : controller.continueWithApple,
                ),
              ],
              if (controller.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  controller.errorMessage!,
                  style: AppTextStyles.caption(
                    colors,
                  ).copyWith(color: colors.error),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
