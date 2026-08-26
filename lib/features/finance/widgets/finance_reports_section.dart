import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/finance/models/finance_month_snapshot.dart';
import 'package:life_daily_app/features/finance/widgets/finance_comparison_section.dart';
import 'package:life_daily_app/features/finance/widgets/finance_health_card.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';

class FinanceReportsSection extends StatelessWidget {
  const FinanceReportsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GetBuilder<FinanceController>(
      id: 'finance',
      builder: (controller) {
        final snapshot = controller.snapshot;
        final budget = snapshot.spendBudget;
        final remainingRatio = budget <= 0
            ? 1.0
            : (snapshot.budgetLeft / budget).clamp(0.0, 1.0);
        final remainingPercent = (remainingRatio * 100).round();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const FinanceHealthCard(),
            const SizedBox(height: AppSpacing.lg),
            const FinanceComparisonSection(),
            const SizedBox(height: AppSpacing.lg),
            GestureDetector(
              onTap: AppNavigator.toMonthPlan,
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            LocaleKeys.financeMonthlyStats.tr,
                            style: AppTextStyles.h6(colors),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: colors.textSecondary,
                          size: AppIconSize.md,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        _Stat(
                          label: LocaleKeys.financeLiving.tr,
                          value: FinanceMonthSnapshot.format(snapshot.spend),
                        ),
                        _Stat(
                          label: LocaleKeys.financeIncome.tr,
                          value: FinanceMonthSnapshot.format(snapshot.income),
                        ),
                        _Stat(
                          label: LocaleKeys.financeFree.tr,
                          value: FinanceMonthSnapshot.format(snapshot.free),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: AppNavigator.toMonthPlan,
              child: AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  LocaleKeys.financeBudgetTitle.tr,
                                  style: AppTextStyles.h6(colors),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: colors.textSecondary,
                                size: AppIconSize.md,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _Line(
                            label: LocaleKeys.financeSpendBudget.tr,
                            value: FinanceMonthSnapshot.format(budget),
                          ),
                          _Line(
                            label: LocaleKeys.financeLiving.tr,
                            value: FinanceMonthSnapshot.format(snapshot.spend),
                          ),
                          const Divider(),
                          _Line(
                            label: LocaleKeys.financeLeft.tr,
                            value: FinanceMonthSnapshot.format(
                              budget > 0 ? snapshot.budgetLeft : snapshot.free,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    SizedBox(
                      width: AppSpacing.xxl * 2,
                      height: AppSpacing.xxl * 2,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size.square(AppSpacing.xxl * 2),
                            painter: _RemainPainter(
                              ratio: remainingRatio,
                              fill: colors.primary,
                              track: colors.border,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$remainingPercent%',
                                style: AppTextStyles.h6(colors),
                              ),
                              Text(
                                LocaleKeys.financeLeft.tr,
                                style: AppTextStyles.caption(colors),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Expanded(
      child: Column(
        children: [
          Text(label, style: AppTextStyles.caption(colors)),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTextStyles.h6(colors)),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body2(colors))),
          Text(value, style: AppTextStyles.body1(colors)),
        ],
      ),
    );
  }
}

class _RemainPainter extends CustomPainter {
  _RemainPainter({
    required this.ratio,
    required this.fill,
    required this.track,
  });

  final double ratio;
  final Color fill;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: math.min(size.width, size.height) / 2 - 6,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    paint.color = track;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, paint);
    paint.color = fill;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * ratio, false, paint);
  }

  @override
  bool shouldRepaint(covariant _RemainPainter oldDelegate) {
    return ratio != oldDelegate.ratio;
  }
}
