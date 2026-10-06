import 'dart:math' as math;

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
import 'package:life_daily_app/features/finance/models/finance_category.dart';
import 'package:life_daily_app/features/finance/models/finance_month_snapshot.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';

class FinanceChartsSection extends StatelessWidget {
  const FinanceChartsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GetBuilder<FinanceController>(
      id: 'finance',
      builder: (controller) {
        final snapshot = controller.snapshot;
        final rows = _rows(controller, snapshot, colors);
        final total = rows.fold<double>(0, (sum, row) => sum + row.amount);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              child: Row(
                children: [
                  SizedBox(
                    width: AppSpacing.xxl * 2 + AppSpacing.md,
                    height: AppSpacing.xxl * 2 + AppSpacing.md,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size.square(AppSpacing.xxl * 2),
                          painter: _DonutPainter(
                            slices: [
                              for (final row in rows) (row.amount, row.color),
                            ],
                            empty: colors.border,
                          ),
                        ),
                        Text(
                          FinanceMonthSnapshot.format(total),
                          style: AppTextStyles.h5(colors),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      children: [
                        for (final row in rows.take(5))
                          _Legend(
                            color: row.color,
                            label: row.label,
                            percent: total <= 0
                                ? 0
                                : (row.amount / total * 100),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final row in rows) _CategoryRow(row: row, total: total),
          ],
        );
      },
    );
  }

  List<_ChartRow> _rows(
    FinanceController controller,
    FinanceMonthSnapshot snapshot,
    AppPalette colors,
  ) {
    if (controller.chartKind == FinanceChartKind.income) {
      final rows = <_ChartRow>[];
      for (final category in controller.incomeCategories) {
        final amount = snapshot.incomeByCategory[category.id] ?? 0;
        if (amount <= 0) continue;
        rows.add(
          _ChartRow(
            label: controller.categoryLabel(category),
            amount: amount,
            color: category.color(colors),
            icon: category.icon,
            category: category,
          ),
        );
      }
      final orphan = snapshot.incomeByCategory.entries
          .where(
            (entry) =>
                entry.value > 0 &&
                !controller.incomeCategories.any(
                  (item) => item.id == entry.key,
                ),
          )
          .fold<double>(0, (sum, entry) => sum + entry.value);
      if (orphan > 0) {
        rows.add(
          _ChartRow(
            label: LocaleKeys.financeCatOtherIncome.tr,
            amount: orphan,
            color: colors.primaryDark,
            icon: Icons.more_horiz_rounded,
          ),
        );
      }
      rows.sort((a, b) => b.amount.compareTo(a.amount));
      return rows;
    }
    final spend = <_ChartRow>[];
    final allocated = <_ChartRow>[];
    for (final category in controller.spendCategories) {
      final amount = snapshot.outflowByCategory[category.id] ?? 0;
      if (amount <= 0) continue;
      final row = _ChartRow(
        label: controller.categoryLabel(category),
        amount: amount,
        color: category.color(colors),
        icon: category.icon,
        category: category,
      );
      if (category.isAllocate) {
        allocated.add(row);
      } else {
        spend.add(row);
      }
    }
    spend.sort((a, b) => b.amount.compareTo(a.amount));
    allocated.sort((a, b) => b.amount.compareTo(a.amount));
    return [...spend, ...allocated];
  }
}

class _ChartRow {
  const _ChartRow({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    this.category,
  });

  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final FinanceCategory? category;
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.color,
    required this.label,
    required this.percent,
  });

  final Color color;
  final String label;
  final double percent;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: AppSpacing.sm,
            height: AppSpacing.sm,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 2),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption(colors),
            ),
          ),
          Text(
            '${percent.toStringAsFixed(1)}%',
            style: AppTextStyles.caption(colors),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.row, required this.total});

  final _ChartRow row;
  final double total;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final ratio = total <= 0 ? 0.0 : row.amount / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: AppSpacing.xl + AppSpacing.sm,
            height: AppSpacing.xl + AppSpacing.sm,
            decoration: BoxDecoration(
              color: row.color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(row.icon, color: row.color, size: AppIconSize.md),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(row.label, style: AppTextStyles.body1(colors)),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: ratio.clamp(0, 1),
                    minHeight: AppSpacing.xs,
                    color: row.color,
                    backgroundColor: colors.border,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                FinanceMonthSnapshot.format(row.amount),
                style: AppTextStyles.h6(colors),
              ),
              Text(
                '${(ratio * 100).toStringAsFixed(1)}%',
                style: AppTextStyles.caption(colors),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.slices, required this.empty});

  final List<(double, Color)> slices;
  final Color empty;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: math.min(size.width, size.height) / 2 - 4,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final total = slices.fold<double>(0, (sum, item) => sum + item.$1);
    if (total <= 0) {
      paint.color = empty;
      canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, paint);
      return;
    }
    var start = -math.pi / 2;
    for (final slice in slices) {
      if (slice.$1 <= 0) continue;
      paint.color = slice.$2;
      final sweep = (slice.$1 / total) * math.pi * 2;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return slices != oldDelegate.slices;
  }
}
