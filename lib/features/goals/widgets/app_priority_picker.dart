import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/models/app_priority.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_palette.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';

class PriorityVisualConfig {
  const PriorityVisualConfig({
    required this.color,
    required this.bgColor,
    required this.icon,
    required this.label,
  });

  final Color color;
  final Color bgColor;
  final IconData icon;
  final String label;

  static PriorityVisualConfig forPriority(
    AppPriority priority,
    AppPalette colors,
  ) {
    return switch (priority) {
      AppPriority.urgent => PriorityVisualConfig(
        color: colors.error,
        bgColor: colors.error.withValues(alpha: 0.14),
        icon: Icons.error_outline_rounded,
        label: LocaleKeys.priorityUrgent.tr,
      ),
      AppPriority.high => PriorityVisualConfig(
        color: colors.warning,
        bgColor: colors.warning.withValues(alpha: 0.14),
        icon: Icons.keyboard_double_arrow_up_rounded,
        label: LocaleKeys.priorityHigh.tr,
      ),
      AppPriority.medium => PriorityVisualConfig(
        color: colors.info,
        bgColor: colors.info.withValues(alpha: 0.14),
        icon: Icons.drag_handle_rounded,
        label: LocaleKeys.priorityMedium.tr,
      ),
      AppPriority.low => PriorityVisualConfig(
        color: const Color(0xFF64748B),
        bgColor: const Color(0xFF64748B).withValues(alpha: 0.14),
        icon: Icons.keyboard_arrow_down_rounded,
        label: LocaleKeys.priorityLow.tr,
      ),
      AppPriority.none => PriorityVisualConfig(
        color: colors.textDisabled,
        bgColor: colors.textDisabled.withValues(alpha: 0.12),
        icon: Icons.remove_rounded,
        label: LocaleKeys.priorityNone.tr,
      ),
    };
  }
}

class GoalPriorityBadge extends StatelessWidget {
  const GoalPriorityBadge({
    super.key,
    required this.priority,
    this.onChanged,
    this.compact = false,
  });

  final AppPriority priority;
  final ValueChanged<AppPriority>? onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final config = PriorityVisualConfig.forPriority(priority, colors);
    final isClickable = onChanged != null;

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.xs + 2 : AppSpacing.sm + 2,
        vertical: compact ? 2 : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: config.color.withValues(alpha: 0.28),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: compact ? 12 : AppIconSize.sm - 2,
            color: config.color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            config.label,
            style: AppTextStyles.caption(colors).copyWith(
              color: config.color,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 11 : 12,
            ),
          ),
          if (isClickable) ...[
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: compact ? 14 : AppIconSize.sm,
              color: config.color.withValues(alpha: 0.8),
            ),
          ],
        ],
      ),
    );

    if (!isClickable) return content;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          final chosen = await AppPriorityPickerSheet.showPriorityPicker(
            context,
            currentPriority: priority,
          );
          if (chosen != null && chosen != priority) {
            onChanged!(chosen);
          }
        },
        child: content,
      ),
    );
  }
}

class TaskPriorityBadge extends StatelessWidget {
  const TaskPriorityBadge({
    super.key,
    required this.priority,
    this.onChanged,
    this.compact = false,
  });

  final AppPriority priority;
  final ValueChanged<AppPriority>? onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final config = PriorityVisualConfig.forPriority(priority, colors);
    final isClickable = onChanged != null;

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.xs + 2 : AppSpacing.sm,
        vertical: compact ? 2 : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: config.color.withValues(alpha: 0.28),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: compact ? 13 : AppIconSize.sm,
            color: config.color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            config.label,
            style: AppTextStyles.caption(colors).copyWith(
              color: config.color,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 11 : 12,
            ),
          ),
          if (isClickable) ...[
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: compact ? 13 : AppIconSize.sm,
              color: config.color.withValues(alpha: 0.8),
            ),
          ],
        ],
      ),
    );

    if (!isClickable) return content;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          final chosen = await AppPriorityPickerSheet.showPriorityPicker(
            context,
            currentPriority: priority,
          );
          if (chosen != null && chosen != priority) {
            onChanged!(chosen);
          }
        },
        child: content,
      ),
    );
  }
}

class AppPriorityPickerSheet {
  static Future<AppPriority?> showPriorityPicker(
    BuildContext context, {
    required AppPriority currentPriority,
  }) {
    final colors = context.appPalette;
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    if (isWide) {
      return showDialog<AppPriority>(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Container(
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: colors.border),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.16),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.flag_rounded,
                        size: AppIconSize.md,
                        color: colors.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        LocaleKeys.selectPriority.tr,
                        style: AppTextStyles.h6(colors),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: Icon(
                          Icons.close_rounded,
                          size: AppIconSize.md,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _PriorityOptionsList(currentPriority: currentPriority),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return showModalBottomSheet<AppPriority>(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.flag_rounded,
                    size: AppIconSize.md,
                    color: colors.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    LocaleKeys.selectPriority.tr,
                    style: AppTextStyles.h6(colors),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _PriorityOptionsList(currentPriority: currentPriority),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityOptionsList extends StatelessWidget {
  const _PriorityOptionsList({required this.currentPriority});

  final AppPriority currentPriority;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PrioritySectionHeader(label: LocaleKeys.prioritySectionUrgent.tr),
        _PriorityOptionTile(
          value: AppPriority.urgent,
          selected: currentPriority == AppPriority.urgent,
          config: PriorityVisualConfig.forPriority(AppPriority.urgent, colors),
          onTap: () => Navigator.of(context).pop(AppPriority.urgent),
        ),
        const SizedBox(height: AppSpacing.xs),
        _PrioritySectionHeader(label: LocaleKeys.prioritySectionHigh.tr),
        _PriorityOptionTile(
          value: AppPriority.high,
          selected: currentPriority == AppPriority.high,
          config: PriorityVisualConfig.forPriority(AppPriority.high, colors),
          onTap: () => Navigator.of(context).pop(AppPriority.high),
        ),
        const SizedBox(height: AppSpacing.xs),
        _PrioritySectionHeader(label: LocaleKeys.prioritySectionStandard.tr),
        _PriorityOptionTile(
          value: AppPriority.medium,
          selected: currentPriority == AppPriority.medium,
          config: PriorityVisualConfig.forPriority(AppPriority.medium, colors),
          onTap: () => Navigator.of(context).pop(AppPriority.medium),
        ),
        _PriorityOptionTile(
          value: AppPriority.low,
          selected: currentPriority == AppPriority.low,
          config: PriorityVisualConfig.forPriority(AppPriority.low, colors),
          onTap: () => Navigator.of(context).pop(AppPriority.low),
        ),
        _PriorityOptionTile(
          value: AppPriority.none,
          selected: currentPriority == AppPriority.none,
          config: PriorityVisualConfig.forPriority(AppPriority.none, colors),
          onTap: () => Navigator.of(context).pop(AppPriority.none),
        ),
      ],
    );
  }
}

class _PrioritySectionHeader extends StatelessWidget {
  const _PrioritySectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        right: AppSpacing.xs,
        top: AppSpacing.sm,
        bottom: AppSpacing.xs,
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(colors).copyWith(
          color: colors.textDisabled,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _PriorityOptionTile extends StatefulWidget {
  const _PriorityOptionTile({
    required this.value,
    required this.selected,
    required this.config,
    required this.onTap,
  });

  final AppPriority value;
  final bool selected;
  final PriorityVisualConfig config;
  final VoidCallback onTap;

  @override
  State<_PriorityOptionTile> createState() => _PriorityOptionTileState();
}

class _PriorityOptionTileState extends State<_PriorityOptionTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final isSelected = widget.selected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? widget.config.bgColor
                : (_hovered ? colors.surface : Colors.transparent),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected
                  ? widget.config.color.withValues(alpha: 0.35)
                  : (_hovered ? colors.border : Colors.transparent),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: widget.config.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.config.color.withValues(alpha: 0.45),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                widget.config.icon,
                size: AppIconSize.sm,
                color: widget.config.color,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  widget.config.label,
                  style: AppTextStyles.body2(colors).copyWith(
                    color: isSelected
                        ? widget.config.color
                        : colors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_rounded,
                  size: AppIconSize.md,
                  color: widget.config.color,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
