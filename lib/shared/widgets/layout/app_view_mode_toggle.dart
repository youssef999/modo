import 'package:flutter/material.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';

class AppViewModeToggle extends StatelessWidget {
  const AppViewModeToggle({
    super.key,
    required this.isGrid,
    required this.onList,
    required this.onGrid,
  });

  final bool isGrid;
  final VoidCallback onList;
  final VoidCallback onGrid;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeButton(
            icon: Icons.view_list_rounded,
            selected: !isGrid,
            onTap: onList,
          ),
          _ModeButton(
            icon: Icons.grid_view_rounded,
            selected: isGrid,
            onTap: onGrid,
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? colors.primary : null,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Icon(
          icon,
          size: AppIconSize.md,
          color: selected ? colors.onPrimary : colors.textSecondary,
        ),
      ),
    );
  }
}
