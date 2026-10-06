import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';

/// Totals for the selected day: money out, money in, and net.
class FinanceDaySummaryCard extends StatelessWidget {
  const FinanceDaySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final locale = MaterialLocalizations.of(context);
    return GetBuilder<FinanceController>(
      id: 'finance',
      builder: (controller) {
        final spend = controller.selectedDaySpend;
        final income = controller.selectedDayIncome;
        final net = income - spend;
        final limit = controller.isSelectedToday
            ? controller.dailySafeLimit
            : 0.0;
        final leftToday = (limit - spend).clamp(0, double.infinity);
        final title = controller.isSelectedToday
            ? LocaleKeys.financeToday.tr
            : locale.formatFullDate(controller.selectedDay);

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.today_rounded,
                      size: AppIconSize.md,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h6(colors),
                    ),
                  ),
                  if (!controller.isSelectedToday)
                    TextButton(
                      onPressed: controller.goToToday,
                      child: Text(
                        LocaleKeys.financeBackToToday.tr,
                        style: AppTextStyles.caption(colors).copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _DayStat(
                    label: LocaleKeys.financeSpent.tr,
                    value: FinanceController.formatAmount(spend),
                    color: colors.error,
                  ),
                  _DayStat(
                    label: LocaleKeys.financeIncome.tr,
                    value: FinanceController.formatAmount(income),
                    color: colors.success,
                  ),
                  _DayStat(
                    label: LocaleKeys.financeNet.tr,
                    value: FinanceController.formatAmount(net),
                    color: net < 0 ? colors.error : colors.primary,
                    emphasize: true,
                  ),
                ],
              ),
              if (limit > 0) ...[
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: (spend / limit).clamp(0, 1).toDouble(),
                    minHeight: AppSpacing.xs,
                    color: spend > limit ? colors.error : colors.primary,
                    backgroundColor: colors.border,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  LocaleKeys.financeLeftToday.trParams({
                    'value': FinanceController.formatAmount(
                      leftToday.toDouble(),
                    ),
                  }),
                  style: AppTextStyles.caption(colors),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DayStat extends StatelessWidget {
  const _DayStat({
    required this.label,
    required this.value,
    required this.color,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Expanded(
      child: Column(
        children: [
          Text(label, style: AppTextStyles.caption(colors)),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style:
                  (emphasize
                          ? AppTextStyles.h5(colors)
                          : AppTextStyles.h6(colors))
                      .copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
