import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/controllers/theme_controller.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';

class AppConfirmDialog {
  AppConfirmDialog._();

  /// Defaults to a delete confirmation; pass [icon] and [confirmLabel] for
  /// other destructive actions.
  static Future<bool> show({
    required String title,
    required String message,
    IconData icon = Icons.delete_outline_rounded,
    String? confirmLabel,
  }) async {
    final colors = Get.isRegistered<ThemeController>()
        ? Get.find<ThemeController>().palette
        : AppColors.light;
    final result = await Get.dialog<bool>(
      _ConfirmBody(
        title: title,
        message: message,
        icon: icon,
        confirmLabel: confirmLabel ?? LocaleKeys.delete.tr,
      ),
      barrierDismissible: true,
      barrierColor: colors.textPrimary.withValues(alpha: 0.45),
    );
    return result ?? false;
  }
}

class _ConfirmBody extends StatelessWidget {
  const _ConfirmBody({
    required this.title,
    required this.message,
    required this.icon,
    required this.confirmLabel,
  });

  final String title;
  final String message;
  final IconData icon;
  final String confirmLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Dialog(
      backgroundColor: colors.card.withValues(alpha: 0),
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppSpacing.md,
            sigmaY: AppSpacing.md,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.card.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: colors.border.withValues(alpha: 0.7)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: colors.error.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: colors.error,
                        size: AppIconSize.xl,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h5(colors),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body2(colors),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: confirmLabel,
                    variant: AppButtonVariant.danger,
                    onPressed: () => Get.back(result: true),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: LocaleKeys.financeCancel.tr,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => Get.back(result: false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
