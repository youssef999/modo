import 'package:flutter/material.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/widgets/app_status_picker.dart';
import 'package:life_daily_app/features/goals/widgets/board_item_card.dart';
import 'package:life_daily_app/features/goals/widgets/tasks_board.dart';

/// The board's items as one scrolling list grouped by status.
class TasksListView extends StatelessWidget {
  const TasksListView({super.key, required this.controller});

  final GoalsController controller;

  static List<Widget> slivers(
    BuildContext context,
    GoalsController controller,
  ) {
    final colors = context.appPalette;
    final grouped = controller.boardItems;
    return [
      for (final status in boardColumns) ...[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: BoardColumnHeader(
              config: StatusVisualConfig.forTaskStatus(status, colors),
              count: grouped[status]?.length ?? 0,
              onAdd: () => openBoardQuickAdd(context, controller, status),
            ),
          ),
        ),
        SliverList.separated(
          itemCount: grouped[status]?.length ?? 0,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) {
            final item = grouped[status]![i];
            return BoardItemCard(
              key: ValueKey(item.key),
              item: item,
              controller: controller,
            );
          },
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppLayout.readableMaxWidth),
        child: CustomScrollView(
          slivers: [
            ...slivers(context, controller),
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
