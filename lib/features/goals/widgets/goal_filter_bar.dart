import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_gradients.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';

class GoalFilterBar extends StatelessWidget {
  const GoalFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return GetBuilder<GoalsController>(
      id: 'goals',
      builder: (controller) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              // All Statuses
              _StatusPill(
                label: LocaleKeys.statusAll.tr,
                count: controller.scopedGoals.length,
                selected: controller.statusFilter == null,
                onTap: () => controller.setStatusFilter(null),
              ),
              // Not Started
              _StatusPill(
                label: LocaleKeys.statusNotStarted.tr,
                dotColor: colors.textSecondary,
                count: controller.statusCount(GoalStatus.notStarted),
                selected: controller.statusFilter == GoalStatus.notStarted,
                onTap: () => controller.setStatusFilter(
                  controller.statusFilter == GoalStatus.notStarted
                      ? null
                      : GoalStatus.notStarted,
                ),
              ),
              // In Progress
              _StatusPill(
                label: LocaleKeys.statusInProgress.tr,
                dotColor: colors.info,
                count: controller.statusCount(GoalStatus.inProgress),
                selected: controller.statusFilter == GoalStatus.inProgress,
                onTap: () => controller.setStatusFilter(
                  controller.statusFilter == GoalStatus.inProgress
                      ? null
                      : GoalStatus.inProgress,
                ),
              ),
              // Done
              _StatusPill(
                label: LocaleKeys.statusDone.tr,
                dotColor: colors.success,
                count: controller.statusCount(GoalStatus.done),
                selected: controller.statusFilter == GoalStatus.done,
                onTap: () => controller.setStatusFilter(
                  controller.statusFilter == GoalStatus.done
                      ? null
                      : GoalStatus.done,
                ),
              ),
              // Archived (only shown if there are archived goals or currently selected)
              if (controller.statusCount(GoalStatus.archived) > 0 ||
                  controller.statusFilter == GoalStatus.archived)
                _StatusPill(
                  label: LocaleKeys.statusArchived.tr,
                  dotColor: colors.textDisabled,
                  count: controller.statusCount(GoalStatus.archived),
                  selected: controller.statusFilter == GoalStatus.archived,
                  onTap: () => controller.setStatusFilter(
                    controller.statusFilter == GoalStatus.archived
                        ? null
                        : GoalStatus.archived,
                  ),
                ),
              // Vertical Divider
              Container(
                height: 22,
                width: 1.5,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                color: colors.border,
              ),
              // Categories
              _CategoryChip(
                label: LocaleKeys.filterAll.tr,
                selected: controller.selectedCategoryId == null && controller.statusFilter == null,
                onTap: controller.clearFilters,
              ),
              ...controller.categories
                  .where((category) => controller.folderCount(category.id) > 0)
                  .map(
                    (category) => _CategoryChip(
                      label: controller.categoryLabel(category),
                      icon: category.icon,
                      accentColor: category.color(colors),
                      count: controller.folderCount(category.id),
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.dotColor,
    this.count,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? dotColor;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final activeColor = dotColor ?? colors.primary;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs + 2,
            ),
            decoration: BoxDecoration(
              color: selected ? activeColor.withValues(alpha: 0.16) : colors.card,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: selected ? activeColor : colors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (dotColor != null) ...[
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: dotColor!.withValues(alpha: 0.5),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs + 2),
                ],
                Text(
                  label,
                  style: AppTextStyles.caption(colors).copyWith(
                    color: selected ? activeColor : colors.textPrimary,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                if (count != null && count! > 0) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? activeColor.withValues(alpha: 0.2)
                          : colors.border.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      '$count',
                      style: AppTextStyles.caption(colors).copyWith(
                        fontSize: 10,
                        color: selected ? activeColor : colors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.accentColor,
    this.count,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? accentColor;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs + 2,
            ),
            decoration: BoxDecoration(
              color: selected ? null : colors.card,
              gradient: selected ? AppGradients.primary(colors) : null,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: selected ? colors.primary : colors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 13,
                    color: selected ? colors.onPrimary : (accentColor ?? colors.textSecondary),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Text(
                  label,
                  style: AppTextStyles.caption(colors).copyWith(
                    color: selected ? colors.onPrimary : colors.textPrimary,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (count != null && count! > 0) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '($count)',
                    style: AppTextStyles.caption(colors).copyWith(
                      fontSize: 10,
                      color: selected
                          ? colors.onPrimary.withValues(alpha: 0.8)
                          : colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
