import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/shell/controllers/shell_controller.dart';
import 'package:life_daily_app/features/shell/widgets/shell_area_style.dart';

class AppAreaSwitcher extends StatelessWidget {
  const AppAreaSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GetBuilder<ShellController>(
      id: 'shell',
      builder: (controller) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Row(
              children: [
                for (final area in ShellArea.values)
                  Expanded(
                    child: _AreaTab(
                      area: area,
                      selected: controller.area == area,
                      onTap: () => controller.selectArea(area),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AreaTab extends StatelessWidget {
  const _AreaTab({
    required this.area,
    required this.selected,
    required this.onTap,
  });

  final ShellArea area;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final accent = area.accent(colors);
    return Material(
      color: selected ? accent : colors.card.withValues(alpha: 0),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.xs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                area.icon,
                size: AppIconSize.md,
                color: selected ? colors.onPrimary : accent,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                area.titleKey.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption(colors).copyWith(
                  color: selected ? colors.onPrimary : colors.textPrimary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
