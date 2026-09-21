import 'package:flutter/material.dart';
import 'package:life_daily_app/core/models/app_view_mode.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';

class AppViewModeToggle extends StatelessWidget {
  const AppViewModeToggle({
    super.key,
    this.mode,
    this.onModeChanged,
    this.isGrid = false,
    this.onList,
    this.onGrid,
  });

  final AppViewMode? mode;
  final ValueChanged<AppViewMode>? onModeChanged;
  final bool isGrid;
  final VoidCallback? onList;
  final VoidCallback? onGrid;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final currentMode = mode ?? (isGrid ? AppViewMode.grid : AppViewMode.list);

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
            selected: currentMode == AppViewMode.list,
            onTap: () {
              if (onModeChanged != null) {
                onModeChanged!(AppViewMode.list);
              } else if (onList != null) {
                onList!();
              }
            },
          ),
          _ModeButton(
            icon: Icons.grid_view_rounded,
            selected: currentMode == AppViewMode.grid,
            onTap: () {
              if (onModeChanged != null) {
                onModeChanged!(AppViewMode.grid);
              } else if (onGrid != null) {
                onGrid!();
              }
            },
          ),
          _ModeButton(
            icon: Icons.view_kanban_rounded,
            selected: currentMode == AppViewMode.kanban,
            onTap: () {
              if (onModeChanged != null) {
                onModeChanged!(AppViewMode.kanban);
              }
            },
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
