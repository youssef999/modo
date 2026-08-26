import 'package:flutter/material.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:get/get.dart';

class FinanceNumpad extends StatelessWidget {
  const FinanceNumpad({
    super.key,
    required this.dateLabel,
    required this.onDigit,
    required this.onDot,
    required this.onBackspace,
    required this.onDate,
    required this.onPlus,
    required this.onMinus,
    required this.onSubmit,
  });

  final String dateLabel;
  final ValueChanged<String> onDigit;
  final VoidCallback onDot;
  final VoidCallback onBackspace;
  final VoidCallback onDate;
  final VoidCallback onPlus;
  final VoidCallback onMinus;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _Key(label: '1', onTap: () => onDigit('1')),
            _Key(label: '2', onTap: () => onDigit('2')),
            _Key(label: '3', onTap: () => onDigit('3')),
            _Key(
              label: dateLabel,
              icon: Icons.calendar_today_outlined,
              accent: true,
              onTap: onDate,
            ),
          ],
        ),
        Row(
          children: [
            _Key(label: '4', onTap: () => onDigit('4')),
            _Key(label: '5', onTap: () => onDigit('5')),
            _Key(label: '6', onTap: () => onDigit('6')),
            _Key(label: '+', onTap: onPlus),
          ],
        ),
        Row(
          children: [
            _Key(label: '7', onTap: () => onDigit('7')),
            _Key(label: '8', onTap: () => onDigit('8')),
            _Key(label: '9', onTap: () => onDigit('9')),
            _Key(label: '−', onTap: onMinus),
          ],
        ),
        Row(
          children: [
            _Key(label: '.', onTap: onDot),
            _Key(label: '0', onTap: () => onDigit('0')),
            _Key(icon: Icons.backspace_outlined, onTap: onBackspace),
            _Key(icon: Icons.check_rounded, filled: true, onTap: onSubmit),
          ],
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    this.label,
    this.icon,
    required this.onTap,
    this.accent = false,
    this.filled = false,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool accent;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final foreground = filled
        ? colors.onPrimary
        : (accent ? colors.primary : colors.textPrimary);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Material(
          color: filled ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: SizedBox(
              height: AppSpacing.xxl,
              child: Center(
                child: icon == null
                    ? Text(
                        label ?? '',
                        style: AppTextStyles.h6(
                          colors,
                        ).copyWith(color: foreground),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon, size: AppIconSize.sm, color: foreground),
                          if (label != null)
                            Text(
                              label!,
                              style: AppTextStyles.caption(
                                colors,
                              ).copyWith(color: foreground),
                            ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String financeTodayLabel(DateTime date) {
  final now = DateTime.now();
  final sameDay =
      date.year == now.year && date.month == now.month && date.day == now.day;
  if (sameDay) return LocaleKeys.financeToday.tr;
  return '${date.day}/${date.month}';
}
