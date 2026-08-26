import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_palette.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/finance/models/finance_month_snapshot.dart';
import 'package:life_daily_app/features/finance/models/finance_period_totals.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';

class FinanceComparisonSection extends StatelessWidget {
  const FinanceComparisonSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GetBuilder<FinanceController>(
      id: 'finance',
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              LocaleKeys.financeCompareTitle.tr,
              style: AppTextStyles.h6(colors),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ComparisonCard(
              title: LocaleKeys.financeCompareWeek.tr,
              comparison: controller.weekComparison,
            ),
            const SizedBox(height: AppSpacing.md),
            _ComparisonCard(
              title: LocaleKeys.financeCompareMonth.tr,
              comparison: controller.monthComparison,
            ),
          ],
        );
      },
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({
    required this.title,
    required this.comparison,
  });

  final String title;
  final FinancePeriodComparison comparison;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.body1(colors)),
          const SizedBox(height: AppSpacing.md),
          _Row(
            colors: colors,
            label: LocaleKeys.financeLiving.tr,
            current: comparison.current.spend,
            previous: comparison.previous.spend,
            lowerIsBetter: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          _Row(
            colors: colors,
            label: LocaleKeys.financeIncome.tr,
            current: comparison.current.income,
            previous: comparison.previous.income,
            lowerIsBetter: false,
          ),
          const SizedBox(height: AppSpacing.sm),
          _Row(
            colors: colors,
            label: LocaleKeys.financeCatSavings.tr,
            current: comparison.current.savings,
            previous: comparison.previous.savings,
            lowerIsBetter: false,
          ),
          const SizedBox(height: AppSpacing.sm),
          _Row(
            colors: colors,
            label: LocaleKeys.financeFree.tr,
            current: comparison.current.free,
            previous: comparison.previous.free,
            lowerIsBetter: false,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.colors,
    required this.label,
    required this.current,
    required this.previous,
    required this.lowerIsBetter,
  });

  final AppPalette colors;
  final String label;
  final double current;
  final double previous;
  final bool lowerIsBetter;

  @override
  Widget build(BuildContext context) {
    final delta = _deltaLabel();
    final deltaColor = _deltaColor();
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: AppTextStyles.body2(colors)),
        ),
        Expanded(
          flex: 2,
          child: Text(
            FinanceMonthSnapshot.format(current),
            textAlign: TextAlign.end,
            style: AppTextStyles.body1(colors),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: AppSpacing.xxl + AppSpacing.lg,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: deltaColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_showIcon()) ...[
                  Icon(
                    _isUp() ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                    size: AppIconSize.sm,
                    color: deltaColor,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Flexible(
                  child: Text(
                    delta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(colors).copyWith(
                      color: deltaColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _deltaLabel() {
    if (current == previous) return LocaleKeys.financeCompareSame.tr;
    if (previous == 0) {
      return current > 0
          ? LocaleKeys.financeCompareNew.tr
          : LocaleKeys.financeCompareSame.tr;
    }
    final pct = (((current - previous) / previous) * 100).round().abs();
    if (pct == 0) return LocaleKeys.financeCompareSame.tr;
    if (current > previous) {
      return LocaleKeys.financeCompareUp.trParams({'value': '$pct'});
    }
    return LocaleKeys.financeCompareDown.trParams({'value': '$pct'});
  }

  Color _deltaColor() {
    if (current == previous || (previous == 0 && current == 0)) {
      return colors.textSecondary;
    }
    if (previous == 0 && current > 0) {
      return lowerIsBetter ? colors.error : colors.success;
    }
    final improved = lowerIsBetter ? current < previous : current > previous;
    if (current == previous) return colors.textSecondary;
    return improved ? colors.success : colors.error;
  }

  bool _showIcon() {
    if (current == previous) return false;
    if (previous == 0) return current > 0;
    return true;
  }

  bool _isUp() => current > previous;
}
