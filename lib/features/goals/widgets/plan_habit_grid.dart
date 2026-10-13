import 'package:flutter/material.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/breakpoints.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';
import 'package:life_daily_app/features/goals/models/plan_period.dart';
import 'package:life_daily_app/features/goals/models/plan_snapshot.dart';
import 'package:life_daily_app/features/goals/widgets/plan_period_labels.dart';

/// Habits × repetitions grid: names pinned at the start, % at the end.
/// Cells stretch to fill wide screens and scroll sideways on narrow ones.
class PlanHabitGrid extends StatelessWidget {
  const PlanHabitGrid({super.key, required this.group, required this.onToggle});

  final PlanHabitGroup group;
  final void Function(GoalModel habit, DateTime start) onToggle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final nameWidth = width >= AppBreakpoints.mobile
            ? AppPlanSize.habitNameWidthWide
            : AppPlanSize.habitNameWidth;
        final available = width - nameWidth - AppPlanSize.percentWidth;
        final count = group.columns.length;
        final fits = count * AppPlanSize.cell <= available;
        final cellWidth = fits ? available / count : AppPlanSize.cell;

        final cells = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: AppPlanSize.headerHeight,
              child: Row(
                children: [
                  for (final column in group.columns)
                    SizedBox(
                      width: cellWidth,
                      child: _ColumnLabel(repeat: group.repeat, start: column),
                    ),
                ],
              ),
            ),
            for (final row in group.rows)
              SizedBox(
                height: AppPlanSize.rowHeight,
                child: Row(
                  children: [
                    for (final cell in row.cells)
                      SizedBox(
                        width: cellWidth,
                        child: _Cell(
                          cell: cell,
                          onTap: () => onToggle(row.habit, cell.start),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: nameWidth,
              child: Column(
                children: [
                  const SizedBox(height: AppPlanSize.headerHeight),
                  for (final row in group.rows)
                    SizedBox(
                      height: AppPlanSize.rowHeight,
                      child: _HabitName(habit: row.habit),
                    ),
                ],
              ),
            ),
            Expanded(
              child: fits
                  ? cells
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: cells,
                    ),
            ),
            SizedBox(
              width: AppPlanSize.percentWidth,
              child: Column(
                children: [
                  const SizedBox(height: AppPlanSize.headerHeight),
                  for (final row in group.rows)
                    SizedBox(
                      height: AppPlanSize.rowHeight,
                      child: _RowPercent(row: row),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HabitName extends StatelessWidget {
  const _HabitName({required this.habit});

  final GoalModel habit;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return InkWell(
      onTap: () => AppNavigator.toGoalDetail(habit.id),
      borderRadius: BorderRadius.circular(AppRadius.xs),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(end: AppSpacing.xs),
          child: Text(
            habit.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body2(
              colors,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _ColumnLabel extends StatelessWidget {
  const _ColumnLabel({required this.repeat, required this.start});

  final PlanPeriod repeat;
  final DateTime start;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final isNow = repeat.contains(start, DateTime.now());
    final tone = isNow ? colors.primary : colors.textSecondary;
    final top = PlanPeriodLabels.cellTop(repeat, start);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isNow ? colors.primary.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs / 2),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (top.isNotEmpty)
                Text(
                  top,
                  style: AppTextStyles.caption(colors).copyWith(color: tone),
                ),
              Text(
                PlanPeriodLabels.cellMain(repeat, start),
                style: AppTextStyles.caption(
                  colors,
                ).copyWith(color: tone, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.cell, required this.onTap});

  final PlanHabitCell cell;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    if (!cell.inRange) return const SizedBox.shrink();
    final enabled = cell.canLog;
    return Center(
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: AppPlanSize.checkBox,
          height: AppPlanSize.checkBox,
          decoration: BoxDecoration(
            color: cell.checked ? colors.success : colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xs),
            border: Border.all(
              color: cell.checked
                  ? colors.success
                  : enabled
                  ? colors.textSecondary.withValues(alpha: 0.5)
                  : colors.border,
            ),
          ),
          child: cell.checked
              ? Icon(
                  Icons.check_rounded,
                  size: AppIconSize.sm,
                  color: colors.onPrimary,
                )
              : null,
        ),
      ),
    );
  }
}

class _RowPercent extends StatelessWidget {
  const _RowPercent({required this.row});

  final PlanHabitRow row;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final percent = (row.progress * 100).round();
    final tone = percent >= 100
        ? colors.success
        : percent >= 50
        ? colors.primary
        : colors.warning;
    return Center(
      child: Text(
        '$percent%',
        style: AppTextStyles.caption(
          colors,
        ).copyWith(color: tone, fontWeight: FontWeight.w700),
      ),
    );
  }
}
