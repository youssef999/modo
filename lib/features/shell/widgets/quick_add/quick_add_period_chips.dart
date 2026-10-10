import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/features/goals/models/plan_period.dart';
import 'package:life_daily_app/features/goals/widgets/plan_period_labels.dart';

import 'quick_add_chip.dart';

/// Day / Week / Month / Year, plus a toggle that turns the entry into a
/// habit repeating every period.
class QuickAddPeriodChips extends StatelessWidget {
  const QuickAddPeriodChips({
    super.key,
    required this.period,
    required this.repeat,
    required this.onPeriodChanged,
    required this.onRepeatChanged,
  });

  final PlanPeriod period;
  final bool repeat;
  final ValueChanged<PlanPeriod> onPeriodChanged;
  final ValueChanged<bool> onRepeatChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final item in PlanPeriod.values)
          QuickAddChip(
            label: PlanPeriodLabels.name(item),
            selected: period == item,
            onTap: () => onPeriodChanged(item),
          ),
        QuickAddChip(
          label: LocaleKeys.planRepeat.tr,
          icon: Icons.repeat_rounded,
          selected: repeat,
          onTap: () => onRepeatChanged(!repeat),
        ),
      ],
    );
  }
}

/// Which week / month / year a span task belongs to: this, next, or picked.
class QuickAddSpanChips extends StatelessWidget {
  const QuickAddSpanChips({
    super.key,
    required this.period,
    required this.value,
    required this.onChanged,
  });

  final PlanPeriod period;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  String get _thisLabel => switch (period) {
    PlanPeriod.day || PlanPeriod.week => LocaleKeys.planThisWeek.tr,
    PlanPeriod.month => LocaleKeys.planThisMonth.tr,
    PlanPeriod.year => LocaleKeys.planThisYear.tr,
  };

  String get _nextLabel => switch (period) {
    PlanPeriod.day || PlanPeriod.week => LocaleKeys.planNextWeek.tr,
    PlanPeriod.month => LocaleKeys.planNextMonth.tr,
    PlanPeriod.year => LocaleKeys.planNextYear.tr,
  };

  Future<void> _pick(BuildContext context, DateTime current) async {
    final earliest = period.shift(current, -1);
    final latest = period.endOf(period.shift(current, 5));
    final picked = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: value.isBefore(earliest) ? value : earliest,
      lastDate: value.isAfter(latest) ? value : latest,
    );
    if (picked != null) onChanged(period.startOf(picked));
  }

  @override
  Widget build(BuildContext context) {
    final current = period.startOf(DateTime.now());
    final next = period.shift(current, 1);
    final selected = period.startOf(value);
    final isCustom = selected != current && selected != next;

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        QuickAddChip(
          label: _thisLabel,
          icon: Icons.today_rounded,
          selected: selected == current,
          onTap: () => onChanged(current),
        ),
        QuickAddChip(
          label: _nextLabel,
          icon: Icons.skip_next_rounded,
          selected: selected == next,
          onTap: () => onChanged(next),
        ),
        QuickAddChip(
          label: isCustom
              ? PlanPeriodLabels.range(period, selected)
              : LocaleKeys.whenPickDate.tr,
          icon: Icons.event_rounded,
          selected: isCustom,
          onTap: () => _pick(context, current),
        ),
      ],
    );
  }
}
