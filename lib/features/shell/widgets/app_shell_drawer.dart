import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/controllers/locale_controller.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/auth/widgets/profile_header.dart';
import 'package:life_daily_app/features/auth/widgets/save_data_card.dart';
import 'package:life_daily_app/features/notifications/widgets/daily_reminder_tile.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';
import 'package:life_daily_app/shared/widgets/layout/app_theme_picker.dart';

class AppShellDrawer extends StatelessWidget {
  const AppShellDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final width = MediaQuery.sizeOf(context).width * 0.86;
    return Drawer(
      backgroundColor: colors.background,
      width: width.clamp(280.0, 360.0),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const ProfileHeader(),
            const SizedBox(height: AppSpacing.lg),
            Text(LocaleKeys.theme.tr, style: AppTextStyles.h6(colors)),
            const SizedBox(height: AppSpacing.sm),
            const AppThemePicker(compact: true),
            const SizedBox(height: AppSpacing.lg),
            Text(LocaleKeys.language.tr, style: AppTextStyles.h6(colors)),
            const SizedBox(height: AppSpacing.sm),
            GetBuilder<LocaleController>(
              builder: (locale) {
                return Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: LocaleKeys.english.tr,
                        variant: locale.isArabic
                            ? AppButtonVariant.secondary
                            : AppButtonVariant.primary,
                        onPressed: () =>
                            locale.setLocale(const Locale('en', 'US')),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        label: LocaleKeys.arabic.tr,
                        variant: locale.isArabic
                            ? AppButtonVariant.primary
                            : AppButtonVariant.secondary,
                        onPressed: () =>
                            locale.setLocale(const Locale('ar', 'SA')),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            const DailyReminderTile(),
            const SizedBox(height: AppSpacing.lg),
            const SaveDataCard(),
          ],
        ),
      ),
    );
  }
}
