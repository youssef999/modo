import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/daily/controllers/plan_controller.dart';
import 'package:life_daily_app/features/goals/models/plan_snapshot.dart';
import 'package:life_daily_app/features/goals/widgets/plan_period_labels.dart';

/// Period navigator (‹ label ›) with the period's overall progress.
class PlanPeriodHeader extends StatelessWidget {
  const PlanPeriodHeader({
    super.key,
    required this.snapshot,
    required this.controller,
  });

  final PlanSnapshot snapshot;
  final PlanController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final complete = snapshot.total > 0 && snapshot.done == snapshot.total;
    final tone = complete ? colors.success : colors.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _NavButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => controller.move(-1),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        PlanPeriodLabels.range(snapshot.period, snapshot.start),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h6(colors),
                      ),
                      if (!controller.isCurrent)
                        TextButton(
                          onPressed: controller.goToNow,
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            foregroundColor: colors.primary,
                          ),
                          child: Text(
                            LocaleKeys.planBackToNow.tr,
                            style: AppTextStyles.caption(colors).copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                _NavButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: () => controller.move(1),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: LinearProgressIndicator(
                      value: snapshot.progress,
                      minHeight: AppSpacing.sm,
                      backgroundColor: colors.surface,
                      color: tone,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  '${snapshot.percent}%',
                  style: AppTextStyles.h5(colors).copyWith(color: tone),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              LocaleKeys.planDoneOf.trParams({
                'done': '${snapshot.done}',
                'total': '${snapshot.total}',
              }),
              style: AppTextStyles.caption(colors),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return IconButton(
      onPressed: onTap,
      style: IconButton.styleFrom(backgroundColor: colors.surface),
      icon: Icon(icon, size: AppIconSize.lg, color: colors.textPrimary),
    );
  }
}
