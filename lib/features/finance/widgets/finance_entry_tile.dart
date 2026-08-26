import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/finance/models/finance_entry.dart';
import 'package:life_daily_app/features/finance/models/finance_month_snapshot.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';
import 'package:life_daily_app/shared/widgets/feedback/app_confirm_dialog.dart';

class FinanceEntryTile extends StatelessWidget {
  const FinanceEntryTile({super.key, required this.entry});

  final FinanceEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final controller = Get.find<FinanceController>();
    final categoryId = entry.categoryId.trim().isEmpty && entry.isInflow
        ? 'salary'
        : entry.categoryId;
    final category = controller.categoryById(categoryId);
    final accent = entry.isInflow
        ? colors.success
        : (category?.color(colors) ?? colors.primary);
    final sign = entry.isInflow ? '+' : '−';
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              category?.icon ?? Icons.payments_outlined,
              color: accent,
              size: AppIconSize.md,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.entryLabel(entry),
                  style: AppTextStyles.h6(colors),
                ),
                Text(
                  MaterialLocalizations.of(
                    context,
                  ).formatMediumDate(entry.occurredAt),
                  style: AppTextStyles.caption(colors),
                ),
              ],
            ),
          ),
          Text(
            '$sign${FinanceMonthSnapshot.format(entry.amount)}',
            style: AppTextStyles.h6(colors).copyWith(color: accent),
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
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await AppConfirmDialog.show(
      title: LocaleKeys.confirmDeleteTitle.tr,
      message: LocaleKeys.confirmDeleteFinance.tr,
    );
    if (!ok) return;
    await Get.find<FinanceController>().deleteEntry(entry);
  }
}
