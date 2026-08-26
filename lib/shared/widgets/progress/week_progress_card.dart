import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';

class WeekProgressCard extends StatelessWidget {
  const WeekProgressCard({
    super.key,
    required this.percent,
    required this.onTap,
  });

  final int percent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.weekCardTitle.tr,
                    style: AppTextStyles.h6(colors),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    LocaleKeys.weekCardHint.tr,
                    style: AppTextStyles.caption(colors),
                  ),
                ],
              ),
            ),
            Text('$percent%', style: AppTextStyles.h5(colors)),
          ],
        ),
      ),
    );
  }
}

class WeekProgressSheet extends StatelessWidget {
  const WeekProgressSheet({
    super.key,
    required this.percent,
    required this.doneLabel,
    required this.totalLabel,
    required this.streak,
  });

  final int percent;
  final String doneLabel;
  final String totalLabel;
  final int streak;

  static Future<void> show({
    required BuildContext context,
    required int percent,
    required String doneLabel,
    required String totalLabel,
    required int streak,
  }) {
    final colors = context.appPalette;
    return Get.bottomSheet<void>(
      WeekProgressSheet(
        percent: percent,
        doneLabel: doneLabel,
        totalLabel: totalLabel,
        streak: streak,
      ),
      backgroundColor: colors.background.withValues(alpha: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: AppCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(LocaleKeys.weekCardTitle.tr, style: AppTextStyles.h5(colors)),
            const SizedBox(height: AppSpacing.md),
            Text(LocaleKeys.weekRate.tr, style: AppTextStyles.caption(colors)),
            Text('$percent%', style: AppTextStyles.h3(colors)),
            const SizedBox(height: AppSpacing.md),
            Text(doneLabel, style: AppTextStyles.body1(colors)),
            Text(totalLabel, style: AppTextStyles.body1(colors)),
            Text(
              LocaleKeys.weekStreak.trParams({'count': '$streak'}),
              style: AppTextStyles.body1(colors),
            ),
            if (percent == 0)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  LocaleKeys.weekEmpty.tr,
                  style: AppTextStyles.caption(colors),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FolderChipRow extends StatelessWidget {
  const FolderChipRow({
    super.key,
    required this.labels,
    required this.ids,
    required this.selectedId,
    required this.onSelected,
  });

  final List<String> labels;
  final List<String> ids;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < ids.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: () => onSelected(ids[i]),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: selectedId == ids[i] ? colors.primary : colors.card,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: colors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Text(
                    labels[i],
                    style: AppTextStyles.caption(colors).copyWith(
                      color: selectedId == ids[i]
                          ? colors.onPrimary
                          : colors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
