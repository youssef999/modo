import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/features/daily/controllers/plan_controller.dart';
import 'package:life_daily_app/features/daily/widgets/plan_child_card.dart';
import 'package:life_daily_app/features/daily/widgets/plan_section_header.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/models/plan_period.dart';
import 'package:life_daily_app/features/goals/models/plan_snapshot.dart';

/// The viewed period split into days / weeks / months, each with its %.
/// Days sit in one row (scrolling on phones); weeks and months wrap.
class PlanBreakdown extends StatelessWidget {
  const PlanBreakdown({
    super.key,
    required this.snapshot,
    required this.plan,
    required this.goals,
  });

  final PlanSnapshot snapshot;
  final PlanController plan;
  final GoalsController goals;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final child = snapshot.period.breakdown;
    if (child == null || snapshot.children.isEmpty) {
      return const SizedBox.shrink();
    }
    final title = switch (child) {
      PlanPeriod.day => LocaleKeys.planDays.tr,
      PlanPeriod.week => LocaleKeys.planWeeks.tr,
      PlanPeriod.month || PlanPeriod.year => LocaleKeys.planMonths.tr,
    };

    Widget card(PlanChild item) => PlanChildCard(
      period: child,
      item: item,
      onOpen: () => plan.open(child, item.start),
      onToggle: (entry) => goals.toggleTask(entry.goal, entry.task.id),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlanSectionHeader(
          icon: Icons.calendar_view_week_rounded,
          tone: colors.primary,
          title: title,
        ),
        const SizedBox(height: AppSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final items = snapshot.children;
            const gap = AppSpacing.sm;

            if (child == PlanPeriod.day) {
              final fitsRow =
                  items.length * AppPlanSize.childMinWidth +
                      (items.length - 1) * gap <=
                  width;
              if (fitsRow) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) const SizedBox(width: gap),
                      Expanded(child: card(items[i])),
                    ],
                  ],
                );
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) const SizedBox(width: gap),
                      SizedBox(
                        width: AppPlanSize.childScrollWidth,
                        child: card(items[i]),
                      ),
                    ],
                  ],
                ),
              );
            }

            final fitting = (width / AppPlanSize.childGridWidth).floor();
            final columns = fitting < 2 ? 2 : fitting;
            final itemWidth = (width - (columns - 1) * gap) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final item in items)
                  SizedBox(width: itemWidth, child: card(item)),
              ],
            );
          },
        ),
      ],
    );
  }
}
