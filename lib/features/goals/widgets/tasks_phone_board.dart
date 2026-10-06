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
import 'package:life_daily_app/features/goals/widgets/tasks_board.dart';

/// Phone board: pinned status tabs, then the selected status's cards.
/// Drop a long-pressed card on a tab to move it there.
class TasksPhoneBoard {
  TasksPhoneBoard._();

  static const double _minSwipeVelocity = 300;

  static GoalTaskStatus _statusOf(BoardItem item) => switch (item) {
    GoalBoardItem(:final goal) => GoalsController.boardColumnOf(goal),
    TaskBoardItem(:final task) => task.status,
  };

  static List<Widget> slivers(
    BuildContext context,
    GoalsController controller,
  ) {
    final grouped = controller.boardItems;
    final status = controller.boardTab;
    final items = grouped[status] ?? const <BoardItem>[];
    return [
      SliverPersistentHeader(
        pinned: true,
        delegate: _TabsHeader(grouped: grouped, controller: controller),
      ),
      if (items.isEmpty)
        SliverToBoxAdapter(
          child: _EmptyTab(status: status, controller: controller),
        )
      else ...[
        SliverList.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) => BoardDraggableItem(
            key: ValueKey(items[i].key),
            item: items[i],
            controller: controller,
          ),
        ),
        SliverToBoxAdapter(
          child: _AddButton(status: status, controller: controller),
        ),
      ],
    ];
  }

  /// Swiping sideways moves to the neighbouring tab (mirrored in RTL).
  static void onSwipe(
    BuildContext context,
    GoalsController controller,
    DragEndDetails details,
  ) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < _minSwipeVelocity) return;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final forward = (velocity < 0) != isRtl;
    final index = boardColumns.indexOf(controller.boardTab);
    final next = (index + (forward ? 1 : -1)).clamp(0, boardColumns.length - 1);
    controller.selectBoardTab(boardColumns[next]);
  }
}

class _TabsHeader extends SliverPersistentHeaderDelegate {
  _TabsHeader({required this.grouped, required this.controller});

  final Map<GoalTaskStatus, List<BoardItem>> grouped;
  final GoalsController controller;

  @override
  double get minExtent => AppBoardSize.statusTabsHeight;

  @override
  double get maxExtent => AppBoardSize.statusTabsHeight;

  @override
  bool shouldRebuild(covariant _TabsHeader oldDelegate) => true;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    final colors = context.appPalette;
    return ColoredBox(
      color: colors.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            for (final status in boardColumns) ...[
              if (status != boardColumns.first)
                const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _StatusTab(
                  status: status,
                  count: grouped[status]?.length ?? 0,
                  selected: controller.boardTab == status,
                  controller: controller,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusTab extends StatelessWidget {
  const _StatusTab({
    required this.status,
    required this.count,
    required this.selected,
    required this.controller,
  });

  final GoalTaskStatus status;
  final int count;
  final bool selected;
  final GoalsController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final config = StatusVisualConfig.forTaskStatus(status, colors);
    return DragTarget<BoardItem>(
      onWillAcceptWithDetails: (d) =>
          TasksPhoneBoard._statusOf(d.data) != status,
      onAcceptWithDetails: (d) => controller.moveBoardItem(d.data, status),
      builder: (context, candidates, _) {
        final highlighted = selected || candidates.isNotEmpty;
        return Material(
          color: highlighted ? config.bgColor : colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(
              color: highlighted ? config.color : colors.border,
              width: candidates.isNotEmpty ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: () => controller.selectBoardTab(status),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      config.icon,
                      size: AppIconSize.sm,
                      color: config.color,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '$count',
                      style: AppTextStyles.body2(
                        colors,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: Text(
                    config.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(colors).copyWith(
                      color: highlighted ? config.color : colors.textSecondary,
                      fontWeight: highlighted
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({required this.status, required this.controller});

  final GoalTaskStatus status;
  final GoalsController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final config = StatusVisualConfig.forTaskStatus(status, colors);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Icon(config.icon, size: AppIconSize.xl, color: colors.textDisabled),
          const SizedBox(height: AppSpacing.sm),
          Text(
            LocaleKeys.noTasksYet.tr,
            textAlign: TextAlign.center,
            style: AppTextStyles.body2(
              colors,
            ).copyWith(color: colors.textSecondary),
          ),
          _AddButton(status: status, controller: controller),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.status, required this.controller});

  final GoalTaskStatus status;
  final GoalsController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Center(
        child: TextButton.icon(
          onPressed: () => openBoardQuickAdd(context, controller, status),
          style: TextButton.styleFrom(foregroundColor: colors.primary),
          icon: const Icon(Icons.add_rounded, size: AppIconSize.md),
          label: Text(
            LocaleKeys.quickAdd.tr,
            style: AppTextStyles.body2(
              colors,
            ).copyWith(color: colors.primary, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
