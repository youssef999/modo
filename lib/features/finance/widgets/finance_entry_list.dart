import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/finance/pages/finance_all_entries_page.dart';
import 'package:life_daily_app/features/finance/widgets/finance_entry_tile.dart';
import 'package:life_daily_app/features/finance/widgets/finance_savings_nudge.dart';
import 'package:life_daily_app/shared/widgets/feedback/app_empty_state.dart';
import 'package:life_daily_app/shared/widgets/layout/app_section_header.dart';

class FinanceEntryList extends StatelessWidget {
  const FinanceEntryList({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FinanceController>(
      id: 'finance',
      builder: (controller) {
        final items = controller.visibleEntries;
        if (items.isEmpty) {
          return ListView(
            children: [
              const FinanceSavingsNudge(),
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
          children: [
            const FinanceSavingsNudge(),
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
      },
    );
  }
}
