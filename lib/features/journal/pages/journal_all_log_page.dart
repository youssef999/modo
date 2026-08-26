import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/features/journal/controllers/journal_controller.dart';
import 'package:life_daily_app/features/journal/widgets/journal_day_strip.dart';
import 'package:life_daily_app/features/journal/widgets/journal_entries_view.dart';
import 'package:life_daily_app/shared/widgets/feedback/app_empty_state.dart';
import 'package:life_daily_app/shared/widgets/layout/app_scaffold.dart';

class JournalAllLogPage extends StatelessWidget {
  const JournalAllLogPage({super.key});

  static const previewLimit = 3;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: LocaleKeys.journalLog.tr,
      body: GetBuilder<JournalController>(
        id: 'journal',
        builder: (controller) {
          final entries = controller.filteredEntries;
          if (entries.isEmpty) {
            return Column(
              children: [
                const JournalDayStrip(),
                const SizedBox(height: AppSpacing.md),
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
          return Column(
            children: [
              const JournalDayStrip(),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: JournalEntriesView(
                  entries: entries,
                  groupByDay: true,
                  showToggle: true,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
