import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/shared/widgets/inputs/app_category_sheet.dart';

typedef _SectionPick = ({String? id, bool create});

/// Phone section filter: one field that opens a list of sections.
class TaskSectionDropdown extends StatelessWidget {
  const TaskSectionDropdown({super.key, required this.controller});

  final GoalsController controller;

  Future<void> _open(BuildContext context) async {
    final colors = context.appPalette;
    final pick = await showModalBottomSheet<_SectionPick>(
      context: context,
      useSafeArea: true,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _SectionSheet(controller: controller),
    );
    if (pick == null || !context.mounted) return;
    if (!pick.create) {
      controller.selectCategory(pick.id);
      return;
    }
    final draft = await AppCategorySheet.show(context);
    if (draft == null) return;
    final id = await controller.addCategory(
      draft.name,
      iconKey: draft.iconKey,
      select: false,
    );
    if (id != null) controller.selectCategory(id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final id = controller.selectedCategoryId;
    final selected = id == null ? null : controller.categoryById(id);
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: colors.border),
      ),
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                selected?.icon ?? Icons.apps_rounded,
                size: AppIconSize.md,
                color: selected?.color(colors) ?? colors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  selected == null
                      ? LocaleKeys.allSections.tr
                      : controller.categoryLabel(selected),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body2(
                    colors,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Icon(
                Icons.expand_more_rounded,
                size: AppIconSize.md,
                color: colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionSheet extends StatelessWidget {
  const _SectionSheet({required this.controller});

  final GoalsController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final current = controller.selectedCategoryId;
    void pick(_SectionPick value) => Navigator.of(context).pop(value);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Text(
            LocaleKeys.taskSection.tr,
            style: AppTextStyles.h6(colors),
          ),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            children: [
              _SectionOption(
                icon: Icons.apps_rounded,
                tone: colors.primary,
                label: LocaleKeys.allSections.tr,
                selected: current == null,
                onTap: () => pick((id: null, create: false)),
              ),
              for (final category in controller.categories)
                _SectionOption(
                  icon: category.icon,
                  tone: category.color(colors),
                  label: controller.categoryLabel(category),
                  selected: current == category.id,
                  onTap: () => pick((id: category.id, create: false)),
                ),
              Divider(color: colors.divider, height: AppSpacing.md),
              _SectionOption(
                icon: Icons.add_rounded,
                tone: colors.primary,
                label: LocaleKeys.addCategory.tr,
                selected: false,
                onTap: () => pick((id: null, create: true)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionOption extends StatelessWidget {
  const _SectionOption({
    required this.icon,
    required this.tone,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final Color tone;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Icon(icon, size: AppIconSize.sm, color: tone),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body1(colors).copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (selected)
              Icon(
                Icons.check_rounded,
                size: AppIconSize.md,
                color: colors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
