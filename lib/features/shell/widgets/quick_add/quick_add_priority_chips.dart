import 'package:flutter/material.dart';
import 'package:life_daily_app/core/models/app_priority.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/features/goals/widgets/app_priority_picker.dart';

import 'quick_add_chip.dart';

class QuickAddPriorityChips extends StatelessWidget {
  const QuickAddPriorityChips({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const options = [
    AppPriority.low,
    AppPriority.medium,
    AppPriority.high,
  ];

  final AppPriority value;
  final ValueChanged<AppPriority> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final option in options)
          Builder(
            builder: (context) {
              final config = PriorityVisualConfig.forPriority(option, colors);
              return QuickAddChip(
                label: config.label,
                icon: config.icon,
                accent: config.color,
                selected: value == option,
                onTap: () => onChanged(option),
              );
            },
          ),
      ],
    );
  }
}
