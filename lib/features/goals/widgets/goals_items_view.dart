import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/models/app_view_mode.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';
import 'package:life_daily_app/features/goals/widgets/goal_card.dart';
import 'package:life_daily_app/features/goals/widgets/goal_grid_card.dart';
import 'package:life_daily_app/features/goals/widgets/goals_kanban_board.dart';
import 'package:life_daily_app/shared/widgets/layout/app_view_mode_toggle.dart';

class GoalsItemsView extends StatelessWidget {
  const GoalsItemsView({
    super.key,
    required this.items,
    this.showToggle = true,
    this.shrinkWrap = false,
  });

  final List<GoalModel> items;
  final bool showToggle;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GoalsController>(
      id: 'goals',
      builder: (controller) {
        final Widget content;
        if (controller.viewMode == AppViewMode.kanban) {
          content = const GoalsKanbanBoard();
        } else if (controller.isGridView) {
          content = _GridItems(items: items, shrinkWrap: shrinkWrap);
        } else {
          content = _ListItems(items: items, shrinkWrap: shrinkWrap);
        }

        if (shrinkWrap) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showToggle) ...[
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: AppViewModeToggle(
                    mode: controller.viewMode,
                    onModeChanged: controller.setViewMode,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              content,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showToggle) ...[
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: AppViewModeToggle(
                  mode: controller.viewMode,
                  onModeChanged: controller.setViewMode,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            Expanded(child: content),
          ],
        );
      },
    );
  }
}

class _ListItems extends StatelessWidget {
  const _ListItems({required this.items, required this.shrinkWrap});

  final List<GoalModel> items;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    if (shrinkWrap) {
      return Column(
        children: [
          for (final goal in items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GoalCard(goal: goal),
            ),
        ],
      );
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: GoalCard(goal: items[index]),
      ),
    );
  }
}

class _GridItems extends StatelessWidget {
  const _GridItems({required this.items, required this.shrinkWrap});

  final List<GoalModel> items;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      gridDelegate:
          const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 340,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.95,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => GoalGridCard(goal: items[index]),
    );
  }
}
