import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/controllers/locale_controller.dart';
import 'package:life_daily_app/core/controllers/theme_controller.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/features/auth/controllers/auth_controller.dart';
import 'package:life_daily_app/features/auth/widgets/save_data_card.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Row(
      children: [
        GetBuilder<LocaleController>(
          builder: (locale) {
            return _GhostIcon(
              icon: Icons.translate_rounded,
              onTap: locale.toggleLocale,
            );
          },
        ),
        const Spacer(),
        GetBuilder<AuthController>(
          id: 'auth',
          builder: (auth) {
            if (auth.isBackedUp) return const SizedBox.shrink();
            return _GhostIcon(
              icon: Icons.cloud_outlined,
              onTap: () {
                Get.bottomSheet(
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: SaveDataCard(),
                  ),
                  backgroundColor: colors.background.withValues(alpha: 0),
                );
              },
            );
          },
        ),
        const SizedBox(width: AppSpacing.xs),
        GetBuilder<ThemeController>(
          builder: (theme) {
            return _GhostIcon(
              icon: Icons.palette_outlined,
              onTap: theme.cycleTheme,
            );
          },
        ),
      ],
    );
  }
}

class _GhostIcon extends StatelessWidget {
  const _GhostIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return IconButton(
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        foregroundColor: colors.textPrimary,
        backgroundColor: colors.card.withValues(alpha: 0.7),
      ),
      icon: Icon(icon, size: AppIconSize.lg),
    );
  }
}
