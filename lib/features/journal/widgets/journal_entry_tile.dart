import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/journal/controllers/journal_controller.dart';
import 'package:life_daily_app/features/journal/models/journal_entry.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';
import 'package:life_daily_app/shared/widgets/feedback/app_confirm_dialog.dart';

class JournalEntryTile extends StatelessWidget {
  const JournalEntryTile({super.key, required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => AppNavigator.toJournalEditor(entry: entry),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.displayTitle, style: AppTextStyles.h6(colors)),
                    if (entry.preview.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        entry.preview,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body2(colors),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () => _confirmDelete(context),
              icon: Icon(
                Icons.close_rounded,
                size: AppIconSize.sm,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await AppConfirmDialog.show(
      title: LocaleKeys.confirmDeleteTitle.tr,
      message: LocaleKeys.confirmDeleteJournal.tr,
    );
    if (!ok) return;
    await Get.find<JournalController>().delete(entry);
  }
}
