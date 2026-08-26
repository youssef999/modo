import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/features/journal/pages/journal_all_log_page.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/journal/controllers/journal_controller.dart';
import 'package:life_daily_app/features/journal/models/journal_folder.dart';
import 'package:life_daily_app/features/journal/widgets/journal_day_strip.dart';
import 'package:life_daily_app/features/journal/widgets/journal_entries_view.dart';
import 'package:life_daily_app/features/shell/controllers/shell_controller.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';
import 'package:life_daily_app/shared/widgets/feedback/app_empty_state.dart';
import 'package:life_daily_app/shared/widgets/folders/folder_grid_card.dart';
import 'package:life_daily_app/shared/widgets/inputs/app_text_field.dart';
import 'package:life_daily_app/shared/widgets/layout/app_scaffold.dart';
import 'package:life_daily_app/shared/widgets/layout/app_section_header.dart';
import 'package:life_daily_app/shared/widgets/progress/week_progress_card.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key, this.embed = false});

  final bool embed;

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final _search = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      embed: widget.embed,
      showHeader: false,
      body: GetBuilder<ShellController>(
        id: 'shell',
        builder: (shell) {
          return GetBuilder<JournalController>(
            id: 'journal',
            builder: (controller) {
              _handleRequests(controller);
              final section = shell.area == ShellArea.journal
                  ? shell.sectionIndex
                  : 0;
              return switch (section) {
                1 => _Log(controller: controller),
                2 => _Folders(controller: controller, shell: shell),
                3 => _Search(controller: controller, search: _search, focus: _searchFocus),
                _ => _Home(controller: controller),
              };
            },
          );
        },
      ),
    );
  }

  void _handleRequests(JournalController controller) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (controller.weekSheetRequested) {
        controller.consumeWeekSheet();
        final week = controller.week;
        await WeekProgressSheet.show(
          context: context,
          percent: week.percent,
          doneLabel: LocaleKeys.weekNotes.trParams({'count': '${week.done}'}),
          totalLabel: '${LocaleKeys.weekAll.tr}: ${week.total}',
          streak: week.streak,
        );
      }
      if (!mounted) return;
      if (controller.searchRequested) {
        controller.consumeSearchFocus();
        _searchFocus.requestFocus();
      }
      if (controller.datePickerRequested) {
        controller.consumeDatePicker();
        if (!context.mounted) return;
        final picked = await showDatePicker(
          context: context,
          initialDate: controller.day,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null && mounted) controller.selectDay(picked);
      }
    });
  }
}

class _Home extends StatelessWidget {
  const _Home({required this.controller});

  final JournalController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const JournalDayStrip(),
        const SizedBox(height: AppSpacing.md),
        WeekProgressCard(
          percent: controller.week.percent,
          onTap: controller.requestWeekSheet,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: LocaleKeys.writeAction.tr,
          onPressed: () => AppNavigator.toJournalEditor(
            folderId: controller.selectedFolderId ?? JournalFolder.generalId,
          ),
        ),
      ],
    );
  }
}

class _Log extends StatelessWidget {
  const _Log({required this.controller});

  final JournalController controller;

  @override
  Widget build(BuildContext context) {
    final entries = controller.filteredEntries;
    if (entries.isEmpty) {
      return Column(
        children: [
          const JournalDayStrip(),
          Expanded(
            child: AppEmptyState(
              icon: Icons.menu_book_outlined,
              title: LocaleKeys.journalEmptyTitle.tr,
              message: LocaleKeys.journalEmptyMessage.tr,
            ),
          ),
        ],
      );
    }
    final preview = controller.recentEntries;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const JournalDayStrip(),
        const SizedBox(height: AppSpacing.md),
        AppSectionHeader(
          title: LocaleKeys.journalLog.tr,
          totalCount: entries.length,
          previewLimit: JournalAllLogPage.previewLimit,
          onViewAll: AppNavigator.toJournalAllLog,
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: JournalEntriesView(
            entries: preview,
            showToggle: true,
          ),
        ),
      ],
    );
  }
}

class _Search extends StatelessWidget {
  const _Search({
    required this.controller,
    required this.search,
    required this.focus,
  });

  final JournalController controller;
  final TextEditingController search;
  final FocusNode focus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextField(
          controller: search,
          focusNode: focus,
          label: LocaleKeys.journalSearch.tr,
          onChanged: controller.setSearch,
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(child: JournalEntriesView(
          entries: controller.filteredEntries,
          groupByDay: false,
          showToggle: true,
        )),
      ],
    );
  }
}

class _Folders extends StatelessWidget {
  const _Folders({required this.controller, required this.shell});

  final JournalController controller;
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
