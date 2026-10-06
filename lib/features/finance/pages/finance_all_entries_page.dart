import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/finance/models/finance_entry.dart';
import 'package:life_daily_app/features/finance/widgets/finance_entry_tile.dart';
import 'package:life_daily_app/features/finance/widgets/finance_month_strip.dart';
import 'package:life_daily_app/shared/widgets/feedback/app_empty_state.dart';
import 'package:life_daily_app/shared/widgets/layout/app_scaffold.dart';

class FinanceAllEntriesPage extends StatelessWidget {
  const FinanceAllEntriesPage({super.key});

  static const previewLimit = 3;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: LocaleKeys.financeRecent.tr,
      body: GetBuilder<FinanceController>(
        id: 'finance',
        builder: (controller) {
          final items = controller.visibleEntries;
          if (items.isEmpty) {
            return Column(
              children: [
                const FinanceMonthStrip(),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: AppEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: LocaleKeys.financeEmptyTitle.tr,
                    message: LocaleKeys.financeEmptyMessage.tr,
                  ),
                ),
              ],
            );
          }
          final grouped = _groupByDay(items);
          final days = grouped.keys.toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FinanceMonthStrip(),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView.builder(
                  itemCount: days.length,
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final dayItems = grouped[day] ?? const [];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Text(
                            MaterialLocalizations.of(
                              context,
                            ).formatMediumDate(day),
                            style: AppTextStyles.h6(context.appPalette),
                          ),
                        ),
                        for (final entry in dayItems)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: FinanceEntryTile(entry: entry),
                          ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Map<DateTime, List<FinanceEntry>> _groupByDay(
    List<FinanceEntry> items,
  ) {
    final map = <DateTime, List<FinanceEntry>>{};
    for (final entry in items) {
      final day = DateTime(
        entry.occurredAt.year,
        entry.occurredAt.month,
        entry.occurredAt.day,
      );
      map.putIfAbsent(day, () => []).add(entry);
    }
    final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final key in keys) key: map[key]!};
  }
}
