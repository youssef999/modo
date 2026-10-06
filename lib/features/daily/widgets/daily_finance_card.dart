import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/breakpoints.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/finance/models/finance_commitment.dart';
import 'package:life_daily_app/features/finance/models/finance_entry.dart';
import 'package:life_daily_app/features/finance/widgets/add_finance_entry_dialog.dart';

class DailyFinanceCard extends StatelessWidget {
  const DailyFinanceCard({
    super.key,
    required this.selectedDate,
    required this.controller,
  });

  final DateTime selectedDate;
  final FinanceController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final spendToday = controller.dailySpendForDate(selectedDate);
    final safeLimit = controller.dailySafeLimit;
    final commitmentsDue = controller.commitmentsDueOnDate(selectedDate);
    final isDesktop =
        MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;

    final limitRatio = safeLimit > 0
        ? (spendToday / safeLimit).clamp(0.0, 1.0)
        : 0.0;
    final isOverLimit = safeLimit > 0 && spendToday > safeLimit;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: colors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  size: AppIconSize.sm,
                  color: colors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                LocaleKeys.todayFinance.tr,
                style: AppTextStyles.h6(
                  colors,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // Quick Add Expense button
              InkWell(
                onTap: () {
                  if (isDesktop) {
                    AddFinanceEntryDialog.show(context);
                  } else {
                    AppNavigator.toFinanceEntry(kind: FinanceKind.expense);
                  }
                },
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 14, color: colors.success),
                      const SizedBox(width: 4),
                      Text(
                        LocaleKeys.quickAddExpense.tr,
                        style: AppTextStyles.caption(colors).copyWith(
                          color: colors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Spending vs Daily Limit Metrics
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.spendToday.tr,
                      style: AppTextStyles.caption(
                        colors,
                      ).copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      FinanceController.formatAmount(spendToday),
                      style: AppTextStyles.h5(colors).copyWith(
                        fontWeight: FontWeight.bold,
                        color: isOverLimit ? colors.error : colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 36,
                width: 1,
                color: colors.border.withValues(alpha: 0.7),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.dailySafeLimit.tr,
                        style: AppTextStyles.caption(
                          colors,
                        ).copyWith(color: colors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        FinanceController.formatAmount(safeLimit),
                        style: AppTextStyles.h5(colors).copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (safeLimit > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: limitRatio,
                minHeight: 5,
                backgroundColor: colors.border.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverLimit ? colors.error : colors.success,
                ),
              ),
            ),
          ],

          // Commitments Due Today (if any)
          if (commitmentsDue.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            Text(
              LocaleKeys.commitmentsDueToday.tr,
              style: AppTextStyles.caption(colors).copyWith(
                fontWeight: FontWeight.bold,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ...commitmentsDue.map(
              (commitment) => _CommitmentDueTile(
                commitment: commitment,
                onTogglePaid: () => controller.toggleCommitmentPaid(commitment),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CommitmentDueTile extends StatelessWidget {
  const _CommitmentDueTile({
    required this.commitment,
    required this.onTogglePaid,
  });

  final FinanceCommitment commitment;
  final VoidCallback onTogglePaid;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          InkWell(
            onTap: onTogglePaid,
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Icon(
              commitment.isPaid
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              size: AppIconSize.md,
              color: commitment.isPaid ? colors.success : colors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              commitment.title,
              style: AppTextStyles.body2(colors).copyWith(
                decoration: commitment.isPaid
                    ? TextDecoration.lineThrough
                    : null,
                color: commitment.isPaid
                    ? colors.textDisabled
                    : colors.textPrimary,
              ),
            ),
          ),
          Text(
            FinanceController.formatAmount(commitment.amount),
            style: AppTextStyles.body2(colors).copyWith(
              fontWeight: FontWeight.bold,
              color: commitment.isPaid
                  ? colors.textDisabled
                  : colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
