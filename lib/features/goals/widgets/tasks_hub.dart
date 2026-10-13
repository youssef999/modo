import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/breakpoints.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/models/app_view_mode.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/widgets/archived_goals_sheet.dart';
import 'package:life_daily_app/features/goals/widgets/board_habits_view.dart';
import 'package:life_daily_app/features/goals/widgets/board_period_bar.dart';
import 'package:life_daily_app/features/goals/widgets/board_period_nav.dart';
import 'package:life_daily_app/features/goals/widgets/task_section_dropdown.dart';
import 'package:life_daily_app/features/goals/widgets/task_section_filter.dart';
import 'package:life_daily_app/features/goals/widgets/tasks_board.dart';
import 'package:life_daily_app/features/goals/widgets/tasks_list_view.dart';
import 'package:life_daily_app/shared/widgets/layout/app_view_mode_toggle.dart';

/// One board for tasks and goals: pick a period on top (Daily … General),
/// then see it as a board (web), a foldable list, or the habit grid.
class TasksHub extends StatelessWidget {
  const TasksHub({super.key});

  static const _wideModes = [
    AppViewMode.kanban,
    AppViewMode.list,
    AppViewMode.habits,
  ];
  static const _phoneModes = [AppViewMode.list, AppViewMode.habits];

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GetBuilder<GoalsController>(
      id: 'goals',
      builder: (controller) {
        final isPhone =
            MediaQuery.sizeOf(context).width < AppBreakpoints.tablet;
        final modes = isPhone ? _phoneModes : _wideModes;
        final mode = modes.contains(controller.viewMode)
            ? controller.viewMode
            : AppViewMode.list;
        final scope = controller.boardScope;
        final items = controller.boardItems;
        final progress = controller.boardProgress(items);

        final periodBar = BoardPeriodBar(
          value: scope.period,
          onChanged: controller.setBoardPeriod,
        );
        final periodNav = BoardPeriodNav(
          scope: scope,
          done: progress.done,
          total: progress.total,
          onMove: controller.moveBoardScope,
          onNow: controller.boardScopeToNow,
        );
        final actions = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => ArchivedGoalsSheet.show(context),
              tooltip: LocaleKeys.statusArchived.tr,
              icon: Icon(
                Icons.inventory_2_outlined,
                size: AppIconSize.md,
                color: colors.textSecondary,
              ),
            ),
            AppViewModeToggle(
              mode: mode,
              modes: modes,
              onModeChanged: controller.setViewMode,
            ),
          ],
        );

        if (isPhone) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    periodBar,
                    const SizedBox(height: AppSpacing.sm),
                    periodNav,
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: TaskSectionDropdown(controller: controller),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        actions,
                      ],
                    ),
                  ],
                ),
              ),
              if (mode == AppViewMode.habits)
                BoardHabitsView.sliver(context, controller)
              else
                ...TasksListView.slivers(context, controller, items),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SizedBox(width: AppLayout.sheetMaxWidth, child: periodBar),
                const SizedBox(width: AppSpacing.lg),
                Expanded(child: periodNav),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TaskSectionFilter(
                    controller: controller,
                    value: controller.selectedCategoryId,
                    onChanged: controller.selectCategory,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                actions,
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: switch (mode) {
                AppViewMode.kanban => TasksBoard(
                  controller: controller,
                  items: items,
                ),
                AppViewMode.habits => BoardHabitsView(controller: controller),
                _ => TasksListView(controller: controller, items: items),
              },
            ),
          ],
        );
      },
    );
  }
}
