import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/widgets/goal_filter_bar.dart';
import 'package:life_daily_app/features/goals/widgets/goals_items_view.dart';
import 'package:life_daily_app/shared/widgets/feedback/app_empty_state.dart';
import 'package:life_daily_app/shared/widgets/layout/app_scaffold.dart';

class GoalsAllPage extends StatelessWidget {
  const GoalsAllPage({super.key, this.doneOnly = false});

  final bool doneOnly;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: doneOnly ? LocaleKeys.navDone.tr : LocaleKeys.goalsRecent.tr,
      body: GetBuilder<GoalsController>(
        id: 'goals',
        builder: (controller) {
          final items = doneOnly
              ? controller.doneGoals
              : (controller.statusFilter != null
                  ? controller.filteredGoals
                  : controller.activeGoals);
          if (items.isEmpty) {
            return AppEmptyState(
              icon: Icons.flag_outlined,
              title: LocaleKeys.goalsEmptyTitle.tr,
              message: LocaleKeys.goalsEmptyMessage.tr,
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!doneOnly) ...[
                const GoalFilterBar(),
                const SizedBox(height: AppSpacing.md),
              ],
              Expanded(child: GoalsItemsView(items: items)),
            ],
          );
        },
      ),
    );
  }
}
