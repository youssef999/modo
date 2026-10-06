import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/utils/week_progress.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/finance/widgets/finance_month_strip.dart';
import 'package:life_daily_app/features/finance/widgets/finance_segmented.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';
import 'package:life_daily_app/shared/widgets/layout/app_day_strip.dart';

/// Day/month switch plus the matching strip. Day is the default view.
/// With [allowDay] false (charts, reports) only the month strip shows.
class FinancePeriodStrip extends StatelessWidget {
  const FinancePeriodStrip({super.key, this.allowDay = true});

  final bool allowDay;

  static const _padding = EdgeInsets.symmetric(
    horizontal: AppSpacing.sm,
    vertical: AppSpacing.sm,
  );

  @override
  Widget build(BuildContext context) {
    if (!allowDay) {
      return const AppCard(padding: _padding, child: FinanceMonthStrip());
    }
    return GetBuilder<FinanceController>(
      id: 'finance',
      builder: (controller) {
        return AppCard(
          padding: _padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FinanceSegmented(
                leftLabel: LocaleKeys.financeDayView.tr,
                rightLabel: LocaleKeys.financeMonthView.tr,
                isLeft: controller.isDayView,
                onLeft: () => controller.selectPeriod(FinancePeriod.day),
                onRight: () => controller.selectPeriod(FinancePeriod.month),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (controller.isDayView)
                _DayWindow(controller: controller)
              else
                const FinanceMonthStrip(),
            ],
          ),
        );
      },
    );
  }
}

class _DayWindow extends StatelessWidget {
  const _DayWindow({required this.controller});

  final FinanceController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Row(
      children: [
        IconButton(
          tooltip: LocaleKeys.previousWeek.tr,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: AppSpacing.xl,
            minHeight: AppSpacing.xl,
          ),
          onPressed: () => controller.shiftDays(-1),
          icon: Icon(
            Icons.chevron_left_rounded,
            size: AppIconSize.lg,
            color: colors.textSecondary,
          ),
        ),
        Expanded(
          child: AppDayStrip(
            days: controller.nearbyDays(),
            selectedKey: WeekProgress.dayKey(controller.selectedDay),
            dayKey: WeekProgress.dayKey,
            onSelect: controller.selectDay,
          ),
        ),
        IconButton(
          tooltip: LocaleKeys.nextWeek.tr,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: AppSpacing.xl,
            minHeight: AppSpacing.xl,
          ),
          onPressed: controller.canShiftDaysForward
              ? () => controller.shiftDays(1)
              : null,
          icon: Icon(
            Icons.chevron_right_rounded,
            size: AppIconSize.lg,
            color: controller.canShiftDaysForward
                ? colors.textSecondary
                : colors.textDisabled,
          ),
        ),
      ],
    );
  }
}
