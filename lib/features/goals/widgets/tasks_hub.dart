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
import 'package:life_daily_app/features/goals/widgets/task_section_dropdown.dart';
import 'package:life_daily_app/features/goals/widgets/task_section_filter.dart';
import 'package:life_daily_app/features/goals/widgets/tasks_phone_board.dart';
import 'package:life_daily_app/features/goals/widgets/tasks_board.dart';
import 'package:life_daily_app/features/goals/widgets/tasks_list_view.dart';
import 'package:life_daily_app/shared/widgets/layout/app_view_mode_toggle.dart';

/// Tasks and goals in one place: sections, list/board, archive.
class TasksHub extends StatelessWidget {
  const TasksHub({super.key});

  static const _modes = [AppViewMode.list, AppViewMode.kanban];

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GetBuilder<GoalsController>(
      id: 'goals',
      builder: (controller) {
        final isBoard = controller.viewMode == AppViewMode.kanban;
        final isPhone =
            MediaQuery.sizeOf(context).width < AppBreakpoints.tablet;
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
              mode: isBoard ? AppViewMode.kanban : AppViewMode.list,
              modes: _modes,
              onModeChanged: controller.setViewMode,
            ),
          ],
        );

        if (isPhone) {
          final scroll = CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: TaskSectionDropdown(controller: controller),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      actions,
                    ],
                  ),
                ),
              ),
              if (isBoard)
                ...TasksPhoneBoard.slivers(context, controller)
              else
                ...TasksListView.slivers(context, controller),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
            ],
          );
          if (!isBoard) return scroll;
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragEnd: (details) =>
                TasksPhoneBoard.onSwipe(context, controller, details),
            child: scroll,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              child: isBoard
                  ? TasksBoard(controller: controller)
                  : TasksListView(controller: controller),
            ),
          ],
        );
      },
    );
  }
}
