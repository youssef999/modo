import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/shell/controllers/shell_controller.dart';
import 'package:life_daily_app/features/shell/widgets/app_area_switcher.dart';
import 'package:life_daily_app/features/shell/widgets/shell_area_style.dart';

class AppShellTopBar extends StatelessWidget {
  const AppShellTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: GetBuilder<ShellController>(
          id: 'shell',
          builder: (controller) {
            final area = controller.area;
            final accent = area.accent(colors);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _MenuButton(
                      onTap: () => Scaffold.of(context).openDrawer(),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Row(
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              child: Icon(
                                area.icon,
                                size: AppIconSize.lg,
                                color: accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  area.titleKey.tr,
                                  style: AppTextStyles.h5(colors),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  area.subtitleKey.tr,
                                  style: AppTextStyles.caption(colors),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const AppAreaSwitcher(),
              ],
            );
          },
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
      ),
      icon: const Icon(Icons.menu_rounded, size: AppIconSize.md),
    );
  }
}
