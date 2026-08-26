import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/shell/controllers/shell_controller.dart';
import 'package:life_daily_app/features/work/controllers/work_controller.dart';
import 'package:life_daily_app/features/work/models/work_folder.dart';
import 'package:life_daily_app/features/work/widgets/work_day_strip.dart';
import 'package:life_daily_app/features/work/widgets/work_items_view.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';
import 'package:life_daily_app/shared/widgets/feedback/app_empty_state.dart';
import 'package:life_daily_app/shared/widgets/folders/folder_grid_card.dart';
import 'package:life_daily_app/shared/widgets/layout/app_scaffold.dart';
import 'package:life_daily_app/shared/widgets/progress/week_progress_card.dart';

class WorkPage extends StatelessWidget {
  const WorkPage({super.key, this.embed = false});

  final bool embed;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      embed: embed,
      showHeader: false,
      body: GetBuilder<ShellController>(
        id: 'shell',
        builder: (shell) {
          return GetBuilder<WorkController>(
            id: 'work',
            builder: (controller) {
              _handleWeekSheet(context, controller);
              final section = shell.area == ShellArea.work
                  ? shell.sectionIndex
                  : 0;
              return switch (section) {
                1 => _OpenList(controller: controller),
                2 => _Folders(controller: controller, shell: shell),
                3 => _DoneList(controller: controller),
                _ => _Home(controller: controller),
              };
            },
          );
        },
      ),
    );
  }

  void _handleWeekSheet(BuildContext context, WorkController controller) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.weekSheetRequested) return;
      controller.consumeWeekSheet();
      final week = controller.week;
      WeekProgressSheet.show(
        context: context,
        percent: week.percent,
        doneLabel: '${LocaleKeys.weekDone.tr}: ${week.done}',
        totalLabel: '${LocaleKeys.weekAll.tr}: ${week.total}',
        streak: week.streak,
      );
    });
  }
}

class _Home extends StatelessWidget {
  const _Home({required this.controller});

  final WorkController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const WorkDayStrip(),
        const SizedBox(height: AppSpacing.md),
        WeekProgressCard(
          percent: controller.week.percent,
          onTap: controller.requestWeekSheet,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: LocaleKeys.writeAction.tr,
          onPressed: () => AppNavigator.toWorkEditor(
            folderId: controller.selectedFolderId ?? WorkFolder.generalId,
          ),
        ),
      ],
    );
  }
}

class _OpenList extends StatelessWidget {
  const _OpenList({required this.controller});

  final WorkController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.openItems;
    if (items.isEmpty) {
      return AppEmptyState(
        icon: Icons.work_outline,
        title: LocaleKeys.workEmptyTitle.tr,
        message: LocaleKeys.workEmptyMessage.tr,
      );
    }
    return WorkItemsView(
      items: items,
      title: LocaleKeys.navTasks.tr,
    );
  }
}

class _DoneList extends StatelessWidget {
  const _DoneList({required this.controller});

  final WorkController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.doneItems;
    if (items.isEmpty) {
      return AppEmptyState(
        icon: Icons.task_alt_outlined,
        title: LocaleKeys.workDoneEmptyTitle.tr,
        message: LocaleKeys.workDoneEmptyMessage.tr,
      );
    }
    return WorkItemsView(
      items: items,
      title: LocaleKeys.workDoneToday.trParams({
        'count': '${controller.doneTodayCount}',
      }),
    );
  }
}

class _Folders extends StatelessWidget {
  const _Folders({required this.controller, required this.shell});

  final WorkController controller;
  final ShellController shell;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final folders = controller.folders
        .where((folder) => controller.folderCount(folder.id) > 0)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(LocaleKeys.foldersHint.tr, style: AppTextStyles.caption(colors)),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: LocaleKeys.addFolder.tr,
          variant: AppButtonVariant.secondary,
          onPressed: () async {
            final name = await FolderNameSheet.show(
              context,
              title: LocaleKeys.addFolder.tr,
            );
            if (name != null) await controller.addFolder(name);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: folders.isEmpty
              ? AppEmptyState(
                  icon: Icons.folder_outlined,
                  title: LocaleKeys.navFolders.tr,
                  message: LocaleKeys.foldersHint.tr,
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1.05,
                  ),
                  itemCount: folders.length,
                  itemBuilder: (context, index) {
                    final folder = folders[index];
                    return FolderGridCard(
                      title: controller.folderLabel(folder),
                      count: controller.folderCount(folder.id),
                      previews: controller.folderTitles(folder.id),
                      onTap: () {
                        controller.selectFolder(folder.id);
                        shell.selectSection(1);
                      },
                      onLongPress: () async {
                        final name = await FolderNameSheet.show(
                          context,
                          title: LocaleKeys.renameFolder.tr,
                          initial: folder.isBuiltIn ? '' : folder.name,
                        );
                        if (name != null) {
                          await controller.renameFolder(folder, name);
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
