import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/core/constants/breakpoints.dart';
import 'package:life_daily_app/features/finance/widgets/add_finance_entry_dialog.dart';
import 'package:life_daily_app/features/finance/models/finance_entry.dart';
import 'package:life_daily_app/features/shell/controllers/shell_controller.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';

class QuickAddSheet {
  QuickAddSheet._();

  static void show(BuildContext context) {
    final colors = context.appPalette;
    final isDesktop = MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;

    final content = Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: AppCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(LocaleKeys.quickAdd.tr, style: AppTextStyles.h5(colors)),
            const SizedBox(height: AppSpacing.md),
            _AddRow(
              icon: Icons.flag_outlined,
              label: LocaleKeys.goalsTitle.tr,
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop();
                Get.find<ShellController>().selectArea(ShellArea.goals);
                AppNavigator.toGoalEditor();
              },
            ),
            _AddRow(
              icon: Icons.account_balance_wallet_outlined,
              label: LocaleKeys.financeTitle.tr,
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop();
                if (isDesktop) {
                  AddFinanceEntryDialog.show(context);
                } else {
                  AppNavigator.toFinanceEntry(kind: FinanceKind.expense);
                }
              },
            ),
          ],
        ),
      ),
    );

    if (isDesktop) {
      showDialog<void>(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: colors.card.withValues(alpha: 0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: content,
          ),
        ),
      );
      return;
    }

    Get.bottomSheet(
      content,
      backgroundColor: colors.background.withValues(alpha: 0),
      barrierColor: colors.textPrimary.withValues(alpha: 0.25),
    );
  }
}

class _AddRow extends StatelessWidget {
  const _AddRow({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, color: colors.primary),
            const SizedBox(width: AppSpacing.md),
            Text(label, style: AppTextStyles.body1(colors)),
          ],
        ),
      ),
    );
  }
}
