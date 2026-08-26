import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/models/app_view_mode.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/journal/controllers/journal_controller.dart';
import 'package:life_daily_app/features/journal/models/journal_entry.dart';
import 'package:life_daily_app/features/journal/widgets/journal_entry_grid_card.dart';
import 'package:life_daily_app/features/journal/widgets/journal_entry_tile.dart';
import 'package:life_daily_app/shared/widgets/layout/app_view_mode_toggle.dart';

class JournalEntriesView extends StatelessWidget {
  const JournalEntriesView({
    super.key,
    required this.entries,
    this.title,
    this.showToggle = true,
    this.groupByDay = false,
    this.shrinkWrap = false,
  });

  final List<JournalEntry> entries;
  final String? title;
  final bool showToggle;
  final bool groupByDay;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GetBuilder<JournalController>(
      id: 'journal',
      builder: (controller) {
        final useGrid = controller.isGridView;
        final content = useGrid
            ? _GridItems(entries: entries, shrinkWrap: shrinkWrap)
            : groupByDay
                ? _TimelineItems(entries: entries, shrinkWrap: shrinkWrap)
                : _ListItems(entries: entries, shrinkWrap: shrinkWrap);

        final toggle = showToggle
            ? AppViewModeToggle(
                isGrid: controller.isGridView,
                onList: () => controller.setViewMode(AppViewMode.list),
                onGrid: () => controller.setViewMode(AppViewMode.grid),
              )
            : null;

        if (shrinkWrap) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null || toggle != null)
                Row(
                  children: [
                    if (title != null)
                      Expanded(
                        child: Text(title!, style: AppTextStyles.h6(colors)),
                      )
                    else
                      const Spacer(),
                    if (toggle != null) toggle,
                  ],
                ),
              if (title != null || toggle != null)
                const SizedBox(height: AppSpacing.sm),
              content,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null || toggle != null)
              Row(
                children: [
                  if (title != null)
                    Expanded(
                      child: Text(title!, style: AppTextStyles.h6(colors)),
                    )
                  else
                    const Spacer(),
                  if (toggle != null) toggle,
                ],
              ),
            if (title != null || toggle != null)
              const SizedBox(height: AppSpacing.sm),
            Expanded(child: content),
          ],
        );
      },
    );
  }
}

class _ListItems extends StatelessWidget {
  const _ListItems({required this.entries, required this.shrinkWrap});

  final List<JournalEntry> entries;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    if (shrinkWrap) {
      return Column(
        children: [
          for (final entry in entries) JournalEntryTile(entry: entry),
        ],
      );
    }
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) => JournalEntryTile(entry: entries[index]),
    );
  }
}

class _TimelineItems extends StatelessWidget {
  const _TimelineItems({required this.entries, required this.shrinkWrap});

  final List<JournalEntry> entries;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final grouped = JournalEntry.groupByDay(entries);
    final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final children = <Widget>[
      for (final key in days) ...[
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(
            MaterialLocalizations.of(context).formatMediumDate(
              JournalEntry.parseDay(key) ?? DateTime.now(),
            ),
            style: AppTextStyles.h6(colors),
          ),
        ),
        for (final entry in grouped[key] ?? const [])
          JournalEntryTile(entry: entry),
        const SizedBox(height: AppSpacing.md),
      ],
    ];

    if (shrinkWrap) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }

    return ListView(
      children: children,
    );
  }
}

class _GridItems extends StatelessWidget {
  const _GridItems({required this.entries, required this.shrinkWrap});

  final List<JournalEntry> entries;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.92,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) =>
          JournalEntryGridCard(entry: entries[index]),
    );
  }
}
