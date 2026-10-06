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
    this.modes = AppViewMode.values,
  });

  final AppViewMode? mode;
  final ValueChanged<AppViewMode>? onModeChanged;
  final bool isGrid;
  final VoidCallback? onList;
  final VoidCallback? onGrid;
  final List<AppViewMode> modes;

  static IconData _icon(AppViewMode mode) => switch (mode) {
    AppViewMode.list => Icons.view_list_rounded,
    AppViewMode.grid => Icons.grid_view_rounded,
    AppViewMode.kanban => Icons.view_kanban_rounded,
  };

  void _select(AppViewMode next) {
    if (onModeChanged != null) {
      onModeChanged!(next);
    } else if (next == AppViewMode.list) {
      onList?.call();
    } else if (next == AppViewMode.grid) {
      onGrid?.call();
    }
  }

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
          for (final m in modes)
            _ModeButton(
              icon: _icon(m),
              selected: currentMode == m,
              onTap: () => _select(m),
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
