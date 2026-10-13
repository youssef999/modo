import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/goals/models/board_scope.dart';
import 'package:life_daily_app/features/goals/widgets/plan_period_labels.dart';

/// ‹ period › with "Now", and a thin bar of finished cards on the board.
/// General has no dates, so only the progress shows.
class BoardPeriodNav extends StatelessWidget {
  const BoardPeriodNav({
    super.key,
    required this.scope,
    required this.done,
    required this.total,
    required this.onMove,
    required this.onNow,
  });

  final BoardScope scope;
  final int done;
  final int total;
  final ValueChanged<int> onMove;
  final VoidCallback onNow;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final period = scope.period;
    final progress = total == 0 ? 0.0 : done / total;
    final complete = total > 0 && done == total;
    final tone = complete ? colors.success : colors.primary;

    final bar = Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: AppSpacing.xs,
              backgroundColor: colors.surface,
              color: tone,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$done/$total · ${(progress * 100).round()}%',
          style: AppTextStyles.caption(
            colors,
          ).copyWith(color: tone, fontWeight: FontWeight.w700),
        ),
      ],
    );

    if (period == null) return bar;

    return Row(
      children: [
        _NavButton(
          icon: Icons.chevron_left_rounded,
          tooltip: LocaleKeys.previous.tr,
          onTap: () => onMove(-1),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      PlanPeriodLabels.range(period, scope.start),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body1(
                        colors,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (!scope.isCurrent()) ...[
                    const SizedBox(width: AppSpacing.xs),
                    InkWell(
                      onTap: onNow,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs / 2,
                        ),
                        child: Text(
                          LocaleKeys.planBackToNow.tr,
                          style: AppTextStyles.caption(colors).copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              bar,
            ],
          ),
        ),
        _NavButton(
          icon: Icons.chevron_right_rounded,
          tooltip: LocaleKeys.next.tr,
          onTap: () => onMove(1),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, size: AppIconSize.lg, color: colors.textPrimary),
    );
  }
}
