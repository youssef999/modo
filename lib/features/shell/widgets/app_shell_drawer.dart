import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/controllers/locale_controller.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/auth/controllers/profile_controller.dart';
import 'package:life_daily_app/features/auth/widgets/save_data_card.dart';
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
            _DrawerHeader(),
            const SizedBox(height: AppSpacing.lg),
            Text(LocaleKeys.theme.tr, style: AppTextStyles.h6(colors)),
            const SizedBox(height: AppSpacing.sm),
            const AppThemePicker(),
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
            const SaveDataCard(),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final greeting = Get.isRegistered<ProfileController>()
        ? GetBuilder<ProfileController>(
            builder: (profile) {
              final name = profile.displayName.trim();
              return Text(
                name.isEmpty
                    ? LocaleKeys.helloGuest.tr
                    : LocaleKeys.helloName.trParams({'name': name}),
                style: AppTextStyles.h5(colors),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            },
          )
        : Text(LocaleKeys.helloGuest.tr, style: AppTextStyles.h5(colors));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: AppIconSize.lg,
                  color: colors.primary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(LocaleKeys.settings.tr, style: AppTextStyles.caption(colors)),
                  greeting,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
