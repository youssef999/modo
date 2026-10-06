import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_gradients.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/widgets/goals_items_view.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/features/goals/widgets/goal_filter_bar.dart';
import 'package:life_daily_app/features/goals/widgets/goal_progress_card.dart';
import 'package:life_daily_app/shared/widgets/feedback/app_empty_state.dart';
import 'package:life_daily_app/shared/widgets/layout/app_section_header.dart';

class GoalsBoard extends StatelessWidget {
  const GoalsBoard({
    super.key,
    this.showHeader = true,
    this.showProgress = true,
    this.showFilter = true,
    this.doneOnly = false,
    this.shrinkWrap = false,
    this.previewLimit,
    this.sectionTitle,
    this.onViewAll,
  });

  final bool showHeader;
  final bool showProgress;
  final bool showFilter;
  final bool doneOnly;
  final bool shrinkWrap;
  final int? previewLimit;
  final String? sectionTitle;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GetBuilder<GoalsController>(
      id: 'goals',
      builder: (controller) {
        final allItems = doneOnly
            ? controller.doneGoals
            : (controller.statusFilter != null
                  ? controller.filteredGoals
                  : controller.activeGoals);
        final items = previewLimit == null
            ? allItems
            : allItems.take(previewLimit!).toList();

        final header = <Widget>[
          if (showHeader) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    LocaleKeys.goalsTitle.tr,
                    style: AppTextStyles.h5(colors),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppGradients.primary(colors),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow,
                        blurRadius: AppSpacing.sm,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => AppNavigator.toGoalEditor(),
                    icon: Icon(
                      Icons.add_rounded,
                      color: colors.onPrimary,
                      size: AppIconSize.lg,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (showProgress) ...[
            const GoalProgressCard(),
            const SizedBox(height: AppSpacing.md),
          ],
          if (showFilter && previewLimit == null) ...[
            const GoalFilterBar(),
            const SizedBox(height: AppSpacing.md),
          ],
          if (previewLimit != null && sectionTitle != null) ...[
            AppSectionHeader(
              title: sectionTitle!,
              totalCount: allItems.length,
              previewLimit: previewLimit!,
              onViewAll: onViewAll,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ];

        final empty = AppEmptyState(
          icon: Icons.flag_outlined,
          title: LocaleKeys.goalsEmptyTitle.tr,
          message: LocaleKeys.goalsEmptyMessage.tr,
        );

        if (shrinkWrap) {
          return ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ...header,
              GoalsItemsView(items: items, shrinkWrap: true, empty: empty),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...header,
            Expanded(
              child: GoalsItemsView(items: items, empty: empty),
            ),
          ],
        );
      },
    );
  }
}
