import 'package:flutter/material.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_palette.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';

class AppPeriodItem {
  const AppPeriodItem({
    required this.key,
    required this.top,
    required this.bottom,
  });

  final String key;
  final String top;
  final String bottom;
}

class AppPeriodStrip extends StatelessWidget {
  const AppPeriodStrip({
    super.key,
    required this.items,
    required this.selectedKey,
    required this.onSelect,
  });

  final List<AppPeriodItem> items;
  final String selectedKey;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _PeriodChip(
              top: items[i].top,
              bottom: items[i].bottom,
              selected: items[i].key == selectedKey,
              colors: colors,
              onTap: () => onSelect(items[i].key),
            ),
          ),
        ],
      ],
    );
  }
}

class AppDayStrip extends StatelessWidget {
  const AppDayStrip({
    super.key,
    required this.days,
    required this.selectedKey,
    required this.dayKey,
    required this.onSelect,
  });

  final List<DateTime> days;
  final String selectedKey;
  final String Function(DateTime value) dayKey;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final locale = MaterialLocalizations.of(context);
    final byKey = {for (final day in days) dayKey(day): day};
    return AppPeriodStrip(
      items: [
        for (final day in days)
          AppPeriodItem(
            key: dayKey(day),
            top: locale.narrowWeekdays[day.weekday % 7],
            bottom: '${day.day}',
          ),
      ],
      selectedKey: selectedKey,
      onSelect: (key) {
        final day = byKey[key];
        if (day != null) onSelect(day);
      },
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.top,
    required this.bottom,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  final String top;
  final String bottom;
  final bool selected;
  final AppPalette colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: selected ? colors.primary : colors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        elevation: selected ? 2 : 0,
        shadowColor: colors.primary.withValues(alpha: 0.25),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: selected
                  ? null
                  : Border.all(color: colors.border.withValues(alpha: 0.8)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
                horizontal: AppSpacing.xs,
              ),
              child: Column(
                children: [
                  Text(
                    top,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(colors).copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? colors.onPrimary : colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    bottom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h6(colors).copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: selected ? colors.onPrimary : colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
