import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/models/board_item.dart';
import 'package:life_daily_app/features/goals/models/goal_task.dart';
import 'package:life_daily_app/features/goals/widgets/app_status_picker.dart';
import 'package:life_daily_app/features/goals/widgets/board_item_card.dart';
import 'package:life_daily_app/features/shell/widgets/quick_add_sheet.dart';
import 'package:life_daily_app/shared/widgets/layout/app_board_columns.dart';

/// Column order shared by the board and the list view.
const boardColumns = [
  GoalTaskStatus.todo,
  GoalTaskStatus.inProgress,
  GoalTaskStatus.pending,
  GoalTaskStatus.done,
];

void openBoardQuickAdd(
  BuildContext context,
  GoalsController controller,
  GoalTaskStatus status,
) {
  QuickAddSheet.show(
    context,
    status: status,
    categoryId: controller.selectedCategoryId,
  );
}

/// Drag-and-drop board mixing big tasks (goals) and standalone tasks.
class TasksBoard extends StatelessWidget {
  const TasksBoard({super.key, required this.controller});

  final GoalsController controller;

  @override
  Widget build(BuildContext context) {
    final grouped = controller.boardItems;
    return AppBoardColumns(
      count: boardColumns.length,
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.md,
      ),
      itemBuilder: (context, index) {
        final status = boardColumns[index];
        return _BoardColumn(
          status: status,
          items: grouped[status] ?? const [],
          controller: controller,
        );
      },
    );
  }
}

class _BoardColumn extends StatelessWidget {
  const _BoardColumn({
    required this.status,
    required this.items,
    required this.controller,
  });

  final GoalTaskStatus status;
  final List<BoardItem> items;
  final GoalsController controller;

  Widget _cards(BuildContext context) {
    final colors = context.appPalette;
    if (items.isEmpty) {
      return Center(
        child: Text(
          LocaleKeys.dragGoalHere.tr,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption(
            colors,
          ).copyWith(color: colors.textDisabled),
        ),
      );
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) => BoardDraggableItem(
        key: ValueKey(items[i].key),
        item: items[i],
        controller: controller,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final config = StatusVisualConfig.forTaskStatus(status, colors);

    return DragTarget<BoardItem>(
      onWillAcceptWithDetails: (details) => !items.contains(details.data),
      onAcceptWithDetails: (details) =>
          controller.moveBoardItem(details.data, status),
      builder: (context, candidates, _) {
        final hovered = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: hovered
                ? config.color.withValues(alpha: 0.08)
                : colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: hovered ? config.color : colors.border,
              width: hovered ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BoardColumnHeader(
                config: config,
                count: items.length,
                onAdd: () => openBoardQuickAdd(context, controller, status),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(child: _cards(context)),
            ],
          ),
        );
      },
    );
  }
}

class BoardColumnHeader extends StatelessWidget {
  const BoardColumnHeader({
    super.key,
    required this.config,
    required this.count,
    required this.onAdd,
  });

  final StatusVisualConfig config;
  final int count;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(config.icon, size: AppIconSize.sm, color: config.color),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  config.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body2(
                    colors,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: config.bgColor,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs / 2,
                  ),
                  child: Text(
                    '$count',
                    style: AppTextStyles.caption(colors).copyWith(
                      color: config.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onAdd,
          visualDensity: VisualDensity.compact,
          tooltip: LocaleKeys.quickAdd.tr,
          icon: Icon(
            Icons.add_rounded,
            size: AppIconSize.md,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class BoardDraggableItem extends StatelessWidget {
  const BoardDraggableItem({
    super.key,
    required this.item,
    required this.controller,
  });

  static const double _feedbackWidth = 260;

  final BoardItem item;
  final GoalsController controller;

  bool _usesMouse(BuildContext context) {
    final platform = Theme.of(context).platform;
    return kIsWeb ||
        platform == TargetPlatform.macOS ||
        platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final card = BoardItemCard(item: item, controller: controller);
    final feedback = Material(
      color: colors.card.withValues(alpha: 0),
      elevation: AppSpacing.sm,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox(
        width: _feedbackWidth,
        child: Transform.rotate(angle: 0.03, child: card),
      ),
    );
    final ghost = Opacity(opacity: 0.35, child: card);

    if (_usesMouse(context)) {
      return Draggable<BoardItem>(
        data: item,
        feedback: feedback,
        childWhenDragging: ghost,
        child: card,
      );
    }
    return LongPressDraggable<BoardItem>(
      data: item,
      feedback: feedback,
      childWhenDragging: ghost,
      child: card,
    );
  }
}
