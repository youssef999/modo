import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/finance/models/finance_entry.dart';
import 'package:life_daily_app/features/finance/models/finance_month_snapshot.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';

class FinanceSavingsNudge extends StatelessWidget {
  const FinanceSavingsNudge({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GetBuilder<FinanceController>(
      id: 'finance',
      builder: (controller) {
        final snapshot = controller.snapshot;
        final hasSavings = snapshot.savings > 0;
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.success.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Icon(
                        Icons.savings_outlined,
                        color: colors.success,
                        size: AppIconSize.lg,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.financeSavingsTitle.tr,
                          style: AppTextStyles.h6(colors),
                        ),
                        Text(
                          hasSavings
                              ? LocaleKeys.financeSavingsProgress.trParams({
                                  'amount': FinanceMonthSnapshot.format(
                                    snapshot.savings,
                                  ),
                                  'percent': '${snapshot.savingsPercent}',
                                })
                              : LocaleKeys.financeSavingsHint.tr,
                          style: AppTextStyles.caption(colors),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: LocaleKeys.financeSavingsAction.tr,
                onPressed: () {
                  controller.selectCategory('savings');
                  AppNavigator.toFinanceEntry(kind: FinanceKind.expense);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
