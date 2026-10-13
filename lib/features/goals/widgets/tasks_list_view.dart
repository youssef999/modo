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
import 'package:life_daily_app/features/goals/widgets/tasks_board.dart';

/// The board's items as one scrolling list of foldable status sections.
/// This is the phone's board.
class TasksListView extends StatelessWidget {
  const TasksListView({
    super.key,
    required this.controller,
    required this.items,
  });

  final GoalsController controller;
  final Map<GoalTaskStatus, List<BoardItem>> items;

  static List<Widget> slivers(
    BuildContext context,
    GoalsController controller,
    Map<GoalTaskStatus, List<BoardItem>> items,
  ) {
    final colors = context.appPalette;
    final isEmpty = items.values.every((list) => list.isEmpty);
    if (isEmpty) {
      return [
        SliverToBoxAdapter(
          child: _EmptyBoard(
            onAdd: () => openBoardQuickAdd(context, controller),
          ),
        ),
      ];
    }
    return [
      for (final status in boardColumns) ...[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: _SectionHeader(
              config: StatusVisualConfig.forTaskStatus(status, colors),
              count: items[status]?.length ?? 0,
              collapsed: controller.collapsedStatuses.contains(status),
              onToggle: () => controller.toggleStatusCollapsed(status),
              onAdd: () => openBoardQuickAdd(context, controller, status),
            ),
          ),
        ),
        if (!controller.collapsedStatuses.contains(status))
          SliverList.separated(
            itemCount: items[status]?.length ?? 0,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) {
              final item = items[status]![i];
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
            ...slivers(context, controller, items),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.config,
    required this.count,
    required this.collapsed,
    required this.onToggle,
    required this.onAdd,
  });

  final StatusVisualConfig config;
  final int count;
  final bool collapsed;
  final VoidCallback onToggle;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: AppSpacing.xs),
        child: Row(
          children: [
            AnimatedRotation(
              turns: collapsed ? -0.25 : 0,
              duration: const Duration(milliseconds: 160),
              child: Icon(
                Icons.expand_more_rounded,
                size: AppIconSize.md,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: BoardColumnHeader(
                config: config,
                count: count,
                onAdd: onAdd,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBoard extends StatelessWidget {
  const _EmptyBoard({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Icon(
            Icons.task_alt_rounded,
            size: AppIconSize.xl,
            color: colors.textDisabled,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            LocaleKeys.planNoTasks.tr,
            textAlign: TextAlign.center,
            style: AppTextStyles.body2(
              colors,
            ).copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: onAdd,
            icon: Icon(
              Icons.add_rounded,
              size: AppIconSize.md,
              color: colors.primary,
            ),
            label: Text(
              LocaleKeys.quickAdd.tr,
              style: AppTextStyles.body2(
                colors,
              ).copyWith(color: colors.primary, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
