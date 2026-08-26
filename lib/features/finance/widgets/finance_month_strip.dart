import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/utils/week_progress.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/shared/widgets/layout/app_day_strip.dart';

class FinanceMonthStrip extends StatelessWidget {
  const FinanceMonthStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = MaterialLocalizations.of(context);
    return GetBuilder<FinanceController>(
      id: 'finance',
      builder: (controller) {
        final months = controller.nearbyMonths();
        final selectedKey = WeekProgress.dayKey(controller.month);
        final byKey = {
          for (final month in months) WeekProgress.dayKey(month): month,
        };
        return AppPeriodStrip(
          items: [
            for (final month in months)
              AppPeriodItem(
                key: WeekProgress.dayKey(month),
                top: _shortMonth(locale, month),
                bottom: '${month.month}',
              ),
          ],
          selectedKey: selectedKey,
          onSelect: (key) {
            final month = byKey[key];
            if (month != null) controller.selectMonth(month);
          },
        );
      },
    );
  }

  String _shortMonth(MaterialLocalizations locale, DateTime month) {
    final full = locale.formatMonthYear(month);
    final parts = full.split(RegExp(r'[\s/،,-]+'));
    final label = parts.isEmpty ? '' : parts.first.trim();
    if (label.isEmpty) return '${month.month}';
    return label.length <= 4 ? label : label.substring(0, 3);
  }
}
