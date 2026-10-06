import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/finance/pages/finance_all_entries_page.dart';
import 'package:life_daily_app/features/finance/widgets/finance_commitments_card.dart';
import 'package:life_daily_app/features/finance/widgets/finance_day_summary_card.dart';
import 'package:life_daily_app/features/finance/widgets/finance_entry_tile.dart';
import 'package:life_daily_app/features/finance/widgets/finance_savings_nudge.dart';
import 'package:life_daily_app/shared/widgets/feedback/app_empty_state.dart';
import 'package:life_daily_app/shared/widgets/layout/app_section_header.dart';

class FinanceEntryList extends StatelessWidget {
  const FinanceEntryList({super.key});

  /// Light inset so card shadows are not clipped by the scroll view edges.
  static const padding = EdgeInsets.fromLTRB(
    AppSpacing.xs,
    AppSpacing.xs,
    AppSpacing.xs,
    AppSpacing.lg,
  );

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FinanceController>(
      id: 'finance',
      builder: (controller) {
        return controller.isDayView
            ? _DayList(controller: controller)
            : _MonthList(controller: controller);
      },
    );
  }
}

/// Daily view: the day's totals and every entry of that day come first.
class _DayList extends StatelessWidget {
  const _DayList({required this.controller});

  final FinanceController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final items = controller.periodEntries;
    return ListView(
      padding: FinanceEntryList.padding,
      children: [
        const FinanceDaySummaryCard(),
        const SizedBox(height: AppSpacing.md),
        AppSectionHeader(title: LocaleKeys.financeDayEntries.tr),
        const SizedBox(height: AppSpacing.sm),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Text(
              LocaleKeys.financeDayEmpty.tr,
              textAlign: TextAlign.center,
              style: AppTextStyles.body2(colors),
            ),
          )
        else
          for (final entry in items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: FinanceEntryTile(entry: entry),
            ),
        const SizedBox(height: AppSpacing.md),
        const FinanceCommitmentsCard(),
        const SizedBox(height: AppSpacing.md),
        const FinanceSavingsNudge(),
      ],
    );
  }
}

class _MonthList extends StatelessWidget {
  const _MonthList({required this.controller});

  final FinanceController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.visibleEntries;
    if (items.isEmpty) {
      return ListView(
        padding: FinanceEntryList.padding,
        children: [
          const FinanceSavingsNudge(),
          const SizedBox(height: AppSpacing.md),
          const FinanceCommitmentsCard(),
          const SizedBox(height: AppSpacing.md),
          AppEmptyState(
            icon: Icons.receipt_long_outlined,
            title: LocaleKeys.financeEmptyTitle.tr,
            message: LocaleKeys.financeEmptyMessage.tr,
          ),
        ],
      );
    }
    final preview = items.take(FinanceAllEntriesPage.previewLimit).toList();
    return ListView(
      padding: FinanceEntryList.padding,
      children: [
        const FinanceSavingsNudge(),
        const SizedBox(height: AppSpacing.md),
        const FinanceCommitmentsCard(),
        const SizedBox(height: AppSpacing.md),
        AppSectionHeader(
          title: LocaleKeys.financeRecent.tr,
          totalCount: items.length,
          previewLimit: FinanceAllEntriesPage.previewLimit,
          onViewAll: AppNavigator.toFinanceAllEntries,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final entry in preview)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: FinanceEntryTile(entry: entry),
          ),
      ],
    );
  }
}
