import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/features/shell/widgets/shell_page_title.dart';
import 'package:life_daily_app/shared/widgets/branding/modo_brand.dart';

/// Mobile shell header: brand row, then the open page's title.
/// Area switching lives in the floating bottom bar.
class AppShellTopBar extends StatelessWidget {
  const AppShellTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.lg),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.5),
            blurRadius: AppSpacing.md,
            offset: const Offset(0, AppSpacing.xs),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _MenuButton(onTap: () => Scaffold.of(context).openDrawer()),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: ModoBrandLockup(
                      logoSize: AppLogoSize.sm,
                      showTagline: false,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const ShellPageTitle(),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return IconButton(
      onPressed: onTap,
      tooltip: LocaleKeys.settings.tr,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        foregroundColor: colors.textPrimary,
        backgroundColor: colors.surface,
        side: BorderSide(color: colors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      icon: const Icon(Icons.menu_rounded, size: AppIconSize.md),
    );
  }
}
