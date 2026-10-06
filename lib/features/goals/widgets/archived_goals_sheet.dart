import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/widgets/goal_card.dart';

/// Archived big tasks, kept out of the board.
class ArchivedGoalsSheet extends StatelessWidget {
  const ArchivedGoalsSheet._();

  static Future<void> show(BuildContext context) {
    final colors = context.appPalette;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: colors.card,
      constraints: const BoxConstraints(maxWidth: AppLayout.sheetMaxWidth),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => const ArchivedGoalsSheet._(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return GetBuilder<GoalsController>(
          id: 'goals',
          builder: (controller) {
            final archived = controller.archivedGoals;
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(
                  LocaleKeys.statusArchived.tr,
                  style: AppTextStyles.h6(colors),
                ),
                const SizedBox(height: AppSpacing.md),
                if (archived.isEmpty)
                  Text(
                    LocaleKeys.noArchived.tr,
                    style: AppTextStyles.body2(
                      colors,
                    ).copyWith(color: colors.textSecondary),
                  ),
                for (final goal in archived)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: GoalCard(goal: goal),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
