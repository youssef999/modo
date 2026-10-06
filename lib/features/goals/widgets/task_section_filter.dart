import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/shell/widgets/quick_add/quick_add_chip.dart';
import 'package:life_daily_app/shared/widgets/inputs/app_category_sheet.dart';

/// Horizontal section filter for the task board, with inline "new section".
class TaskSectionFilter extends StatelessWidget {
  const TaskSectionFilter({
    super.key,
    required this.controller,
    required this.value,
    required this.onChanged,
  });

  final GoalsController controller;
  final String? value;
  final ValueChanged<String?> onChanged;

  Future<void> _create(BuildContext context) async {
    final draft = await AppCategorySheet.show(context);
    if (draft == null) return;
    final id = await controller.addCategory(
      draft.name,
      iconKey: draft.iconKey,
      select: false,
    );
    if (id != null) onChanged(id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          QuickAddChip(
            label: LocaleKeys.allSections.tr,
            icon: Icons.apps_rounded,
            selected: value == null,
            onTap: () => onChanged(null),
          ),
          for (final category in controller.categories) ...[
            const SizedBox(width: AppSpacing.xs),
            QuickAddChip(
              label: controller.categoryLabel(category),
              icon: category.icon,
              accent: category.color(colors),
              selected: value == category.id,
              onTap: () => onChanged(category.id),
            ),
          ],
          const SizedBox(width: AppSpacing.xs),
          QuickAddChip(
            label: LocaleKeys.addCategory.tr,
            icon: Icons.add_rounded,
            selected: false,
            onTap: () => _create(context),
          ),
        ],
      ),
    );
  }
}
