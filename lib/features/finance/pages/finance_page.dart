import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/finance/widgets/finance_charts_section.dart';
import 'package:life_daily_app/features/finance/widgets/finance_entry_list.dart';
import 'package:life_daily_app/features/finance/widgets/finance_month_strip.dart';
import 'package:life_daily_app/features/finance/widgets/finance_reports_section.dart';
import 'package:life_daily_app/features/finance/widgets/finance_segmented.dart';
import 'package:life_daily_app/features/shell/controllers/shell_controller.dart';
import 'package:life_daily_app/shared/widgets/layout/app_scaffold.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key, this.embed = false});

  final bool embed;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      embed: embed,
      showHeader: false,
      body: GetBuilder<ShellController>(
        id: 'shell',
        builder: (shell) {
          return GetBuilder<FinanceController>(
            id: 'finance',
            builder: (controller) {
              final section = shell.area == ShellArea.finance
                  ? shell.sectionIndex
                  : 0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (section == 1) ...[
                    FinanceSegmented(
                      leftLabel: LocaleKeys.financeExpenses.tr,
                      rightLabel: LocaleKeys.financeIncome.tr,
                      isLeft: controller.chartKind == FinanceChartKind.expense,
                      onLeft: () =>
                          controller.selectChartKind(FinanceChartKind.expense),
                      onRight: () =>
                          controller.selectChartKind(FinanceChartKind.income),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  const FinanceMonthStrip(),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: switch (section) {
                      1 => const SingleChildScrollView(
                        child: FinanceChartsSection(),
                      ),
                      2 => const SingleChildScrollView(
                        child: FinanceReportsSection(),
                      ),
                      _ => const FinanceEntryList(),
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
