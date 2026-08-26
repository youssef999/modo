import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/finance/models/finance_month_snapshot.dart';

class FinanceCategoryStrip extends StatelessWidget {
  const FinanceCategoryStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GetBuilder<FinanceController>(
      id: 'finance',
      builder: (controller) {
        final snapshot = controller.snapshot;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.financeByCategory.tr,
              style: AppTextStyles.h6(colors),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: AppSpacing.xxl + AppSpacing.xl,
              child: Builder(
                builder: (context) {
                  final populated = controller.categories
                      .where(
                        (category) =>
                            (snapshot.outflowByCategory[category.id] ?? 0) > 0,
                      )
                      .toList();
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: populated.length + 1,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      if (index == populated.length) {
                        return _AddChip(
                          onTap: () => AppNavigator.toFinanceCategory(),
                        );
                      }
                      final category = populated[index];
                      final selected =
                          controller.selectedCategoryId == category.id;
                      final spent =
                          snapshot.outflowByCategory[category.id] ?? 0;
                      return _CategoryChip(
                        icon: category.icon,
                        color: category.color(colors),
                        label: controller.categoryLabel(category),
                        amount: FinanceMonthSnapshot.format(spent),
                        selected: selected,
                        onTap: () => controller.selectCategory(category.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.icon,
    required this.color,
    required this.label,
    required this.amount,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String amount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.16) : colors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: selected ? color : colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: AppIconSize.sm, color: color),
                const SizedBox(width: AppSpacing.xs),
                Text(label, style: AppTextStyles.caption(colors)),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(amount, style: AppTextStyles.h6(colors)),
          ],
        ),
      ),
    );
  }
}

class _AddChip extends StatelessWidget {
  const _AddChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Icon(
              Icons.add_rounded,
              size: AppIconSize.md,
              color: colors.primary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              LocaleKeys.addCategory.tr,
              style: AppTextStyles.caption(colors),
            ),
          ],
        ),
      ),
    );
  }
}
