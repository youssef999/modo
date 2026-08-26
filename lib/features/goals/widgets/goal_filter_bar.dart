import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_gradients.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';

class GoalFilterBar extends StatelessWidget {
  const GoalFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GoalsController>(
      id: 'goals',
      builder: (controller) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _Chip(
                label: LocaleKeys.filterAll.tr,
                selected: controller.selectedCategoryId == null,
                onTap: () => controller.selectCategory(null),
              ),
              ...controller.categories
                  .where((category) => controller.folderCount(category.id) > 0)
                  .map(
                    (category) => _Chip(
                      label: controller.categoryLabel(category),
                      selected: controller.selectedCategoryId == category.id,
                      onTap: () => controller.selectCategory(category.id),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected ? null : colors.card,
            gradient: selected ? AppGradients.primary(colors) : null,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: selected ? colors.primary : colors.border,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.caption(
              colors,
            ).copyWith(color: selected ? colors.onPrimary : colors.textPrimary),
          ),
        ),
      ),
    );
  }
}
