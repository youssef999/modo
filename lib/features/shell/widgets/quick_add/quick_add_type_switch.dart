import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/shell/models/quick_add_type.dart';

class QuickAddTypeSwitch extends StatelessWidget {
  const QuickAddTypeSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final QuickAddType value;
  final ValueChanged<QuickAddType> onChanged;

  static (String, IconData) _meta(QuickAddType type) => switch (type) {
    QuickAddType.task => (
      LocaleKeys.addTypeTask,
      Icons.check_circle_outline_rounded,
    ),
    QuickAddType.money => (
      LocaleKeys.addTypeMoney,
      Icons.account_balance_wallet_outlined,
    ),
    QuickAddType.goal => (LocaleKeys.addTypeGoal, Icons.flag_outlined),
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs / 2),
        child: Row(
          children: [
            for (final type in QuickAddType.values)
              Expanded(
                child: _Segment(
                  label: _meta(type).$1.tr,
                  icon: _meta(type).$2,
                  selected: value == type,
                  onTap: () => onChanged(type),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final foreground = selected ? colors.onPrimary : colors.textSecondary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? colors.primary : null,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppIconSize.sm, color: foreground),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption(
                  colors,
                ).copyWith(color: foreground, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
