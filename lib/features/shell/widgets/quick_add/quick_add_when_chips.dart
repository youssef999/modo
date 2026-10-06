import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';

import 'quick_add_chip.dart';

/// Picks a due day for a new task; `null` means "Anytime".
class QuickAddWhenChips extends StatelessWidget {
  const QuickAddWhenChips({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> _pickDate(BuildContext context) async {
    final today = _dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? today,
      firstDate: today.subtract(const Duration(days: 365)),
      lastDate: today.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) onChanged(_dateOnly(picked));
  }

  @override
  Widget build(BuildContext context) {
    final today = _dateOnly(DateTime.now());
    final tomorrow = today.add(const Duration(days: 1));
    final selected = value == null ? null : _dateOnly(value!);
    final isToday = selected == today;
    final isTomorrow = selected == tomorrow;
    final isCustom = selected != null && !isToday && !isTomorrow;
    final customLabel = isCustom
        ? DateFormat('d MMM', Get.locale?.languageCode).format(selected)
        : LocaleKeys.whenPickDate.tr;

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        QuickAddChip(
          label: LocaleKeys.whenToday.tr,
          icon: Icons.today_rounded,
          selected: isToday,
          onTap: () => onChanged(today),
        ),
        QuickAddChip(
          label: LocaleKeys.whenTomorrow.tr,
          icon: Icons.wb_sunny_outlined,
          selected: isTomorrow,
          onTap: () => onChanged(tomorrow),
        ),
        QuickAddChip(
          label: customLabel,
          icon: Icons.event_rounded,
          selected: isCustom,
          onTap: () => _pickDate(context),
        ),
        QuickAddChip(
          label: LocaleKeys.whenAnytime.tr,
          icon: Icons.all_inclusive_rounded,
          selected: selected == null,
          onTap: () => onChanged(null),
        ),
      ],
    );
  }
}
