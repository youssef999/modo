import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/widgets/goal_progress_card.dart';
import 'package:life_daily_app/features/goals/widgets/goals_board.dart';
import 'package:life_daily_app/features/goals/widgets/tasks_hub.dart';
import 'package:life_daily_app/features/shell/controllers/shell_controller.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';
import 'package:life_daily_app/shared/widgets/feedback/app_empty_state.dart';
import 'package:life_daily_app/shared/widgets/folders/folder_grid_card.dart';
import 'package:life_daily_app/shared/widgets/layout/app_scaffold.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key, this.embed = false});

  final bool embed;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      embed: embed,
      showHeader: false,
      body: GetBuilder<ShellController>(
        id: 'shell',
        builder: (shell) {
          return GetBuilder<GoalsController>(
            id: 'goals',
            builder: (controller) {
              final section = shell.area == ShellArea.goals
                  ? shell.sectionIndex
                  : 0;
              return switch (section) {
                1 => const SingleChildScrollView(child: GoalProgressCard()),
                2 => _Folders(controller: controller, shell: shell),
                3 => const GoalsBoard(
                  showHeader: false,
                  showProgress: false,
                  showFilter: true,
                  doneOnly: true,
                ),
                _ => const TasksHub(),
              };
            },
          );
        },
      ),
    );
  }
}

class _Folders extends StatelessWidget {
  const _Folders({required this.controller, required this.shell});

  final GoalsController controller;
  final ShellController shell;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final folders = controller.categories
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
            if (name != null) await controller.addCategory(name);
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
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 320,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: folders.length,
                  itemBuilder: (context, index) {
                    final folder = folders[index];
                    return FolderGridCard(
                      title: controller.categoryLabel(folder),
                      count: controller.folderCount(folder.id),
                      previews: controller.folderTitles(folder.id),
                      onTap: () {
                        controller.selectCategory(folder.id);
                        shell.selectSection(0);
                      },
                      onLongPress: () async {
                        final name = await FolderNameSheet.show(
                          context,
                          title: LocaleKeys.renameFolder.tr,
                          initial: folder.name,
                        );
                        if (name != null) {
                          await controller.renameCategory(folder, name);
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
