import 'package:flutter/material.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';

/// Icon + title + count, with an optional add button at the end.
class PlanSectionHeader extends StatelessWidget {
  const PlanSectionHeader({
    super.key,
    required this.icon,
    required this.tone,
    required this.title,
    this.count,
    this.onAdd,
    this.addTooltip,
  });

  final IconData icon;
  final Color tone;
  final String title;
  final int? count;
  final VoidCallback? onAdd;
  final String? addTooltip;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: tone.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Icon(icon, size: AppIconSize.sm, color: tone),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.h6(colors),
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: AppSpacing.xs),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs / 2,
              ),
              child: Text(
                '$count',
                style: AppTextStyles.caption(
                  colors,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
        const Spacer(),
        if (onAdd != null)
          IconButton(
            onPressed: onAdd,
            tooltip: addTooltip,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.add_rounded,
              size: AppIconSize.md,
              color: colors.primary,
            ),
          ),
      ],
    );
  }
}
