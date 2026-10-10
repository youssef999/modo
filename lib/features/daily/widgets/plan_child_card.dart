import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/goals/models/daily_task_groups.dart';
import 'package:life_daily_app/features/goals/models/plan_period.dart';
import 'package:life_daily_app/features/goals/models/plan_snapshot.dart';
import 'package:life_daily_app/features/goals/widgets/plan_period_labels.dart';
import 'package:life_daily_app/features/shell/widgets/quick_add_sheet.dart';

/// One day / week / month of the breakdown: label, %, and its first tasks.
/// Tapping the card opens that period.
class PlanChildCard extends StatelessWidget {
  const PlanChildCard({
    super.key,
    required this.period,
    required this.item,
    required this.onOpen,
    required this.onToggle,
  });

  final PlanPeriod period;
  final PlanChild item;
  final VoidCallback onOpen;
  final ValueChanged<GoalTaskEntry> onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final isNow = period.contains(item.start, DateTime.now());
    final percent = (item.progress * 100).round();
    final tone = item.total > 0 && item.done == item.total
        ? colors.success
        : colors.primary;
    final preview = item.tasks.take(AppPlanSize.childPreviewTasks).toList();
    final hidden = item.tasks.length - preview.length;

    return Material(
      color: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(
          color: isNow ? colors.primary : colors.border,
          width: isNow ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      PlanPeriodLabels.short(period, item.start),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body2(colors).copyWith(
                        fontWeight: FontWeight.w700,
                        color: isNow ? colors.primary : colors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    item.total == 0 ? '–' : '$percent%',
                    style: AppTextStyles.caption(
                      colors,
                    ).copyWith(color: tone, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: LinearProgressIndicator(
                  value: item.progress,
                  minHeight: AppSpacing.xs,
                  backgroundColor: colors.surface,
                  color: tone,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              for (final entry in preview)
                _TaskLine(entry: entry, onToggle: () => onToggle(entry)),
              if (hidden > 0)
                Text(
                  LocaleKeys.planMore.trParams({'count': '$hidden'}),
                  style: AppTextStyles.caption(
                    colors,
                  ).copyWith(color: colors.textSecondary),
                ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: IconButton(
                  onPressed: () => QuickAddSheet.show(
                    context,
                    date: item.start,
                    period: period,
                  ),
                  tooltip: LocaleKeys.addTask.tr,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.add_rounded,
                    size: AppIconSize.md,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskLine extends StatelessWidget {
  const _TaskLine({required this.entry, required this.onToggle});

  final GoalTaskEntry entry;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final done = entry.task.isCompleted;
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(AppRadius.xs),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs / 2),
        child: Row(
          children: [
            Icon(
              done
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              size: AppIconSize.sm,
              color: done ? colors.success : colors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                entry.task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption(colors).copyWith(
                  color: done ? colors.textDisabled : colors.textPrimary,
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
