import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_palette.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/finance/models/finance_entry.dart';
import 'package:life_daily_app/features/finance/models/finance_month_snapshot.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';

class FinanceHealthCard extends StatelessWidget {
  const FinanceHealthCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GetBuilder<FinanceController>(
      id: 'finance',
      builder: (controller) {
        final snapshot = controller.snapshot;
        final palette = _tone(colors, snapshot.health);
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: palette.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      _icon(snapshot.health),
                      color: palette,
                      size: AppIconSize.lg,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title(snapshot.health),
                          style: AppTextStyles.h5(colors),
                        ),
                        Text(
                          _hint(snapshot.health),
                          style: AppTextStyles.body2(colors),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: LinearProgressIndicator(
                  value: snapshot.reference <= 0
                      ? 0
                      : snapshot.spentRatio.clamp(0, 1),
                  minHeight: AppSpacing.xs,
                  color: palette,
                  backgroundColor: colors.border,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _Stat(
                    label: LocaleKeys.financeIncome.tr,
                    value: FinanceMonthSnapshot.format(snapshot.income),
                  ),
                  _Stat(
                    label: LocaleKeys.financeLiving.tr,
                    value: FinanceMonthSnapshot.format(snapshot.spend),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _Stat(
                    label: LocaleKeys.financeFree.tr,
                    value: FinanceMonthSnapshot.format(snapshot.free),
                    emphasize: true,
                  ),
                  _Stat(
                    label: LocaleKeys.financeAllocated.tr,
                    value: FinanceMonthSnapshot.format(snapshot.allocated),
                  ),
                ],
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: snapshot.health == FinanceHealth.unknown
                      ? () => AppNavigator.toFinanceEntry(
                          kind: FinanceKind.income,
                        )
                      : AppNavigator.toMonthPlan,
                  child: Text(
                    snapshot.health == FinanceHealth.unknown
                        ? LocaleKeys.financeIncome.tr
                        : LocaleKeys.financeMonthPlan.tr,
                    style: AppTextStyles.caption(colors).copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _tone(AppPalette colors, FinanceHealth health) {
    return switch (health) {
      FinanceHealth.good => colors.success,
      FinanceHealth.watch => colors.warning,
      FinanceHealth.bad => colors.error,
      FinanceHealth.unknown => colors.info,
    };
  }

  IconData _icon(FinanceHealth health) {
    return switch (health) {
      FinanceHealth.good => Icons.sentiment_satisfied_alt_outlined,
      FinanceHealth.watch => Icons.sentiment_neutral_outlined,
      FinanceHealth.bad => Icons.sentiment_dissatisfied_outlined,
      FinanceHealth.unknown => Icons.savings_outlined,
    };
  }

  String _title(FinanceHealth health) {
    return switch (health) {
      FinanceHealth.good => LocaleKeys.financeHealthGood.tr,
      FinanceHealth.watch => LocaleKeys.financeHealthWatch.tr,
      FinanceHealth.bad => LocaleKeys.financeHealthBad.tr,
      FinanceHealth.unknown => LocaleKeys.financeHealthUnknown.tr,
    };
  }

  String _hint(FinanceHealth health) {
    return switch (health) {
      FinanceHealth.good => LocaleKeys.financeHealthGoodHint.tr,
      FinanceHealth.watch => LocaleKeys.financeHealthWatchHint.tr,
      FinanceHealth.bad => LocaleKeys.financeHealthBadHint.tr,
      FinanceHealth.unknown => LocaleKeys.financeHealthUnknownHint.tr,
    };
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Expanded(
      child: Column(
        children: [
          Text(label, style: AppTextStyles.caption(colors)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style:
                (emphasize
                        ? AppTextStyles.h5(colors)
                        : AppTextStyles.h6(colors))
                    .copyWith(
                      color: emphasize ? colors.primary : colors.textPrimary,
                    ),
          ),
        ],
      ),
    );
  }
}
