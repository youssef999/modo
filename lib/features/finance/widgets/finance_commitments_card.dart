import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/finance/models/finance_commitment.dart';
import 'package:life_daily_app/features/finance/models/finance_month_snapshot.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';

class FinanceCommitmentsCard extends StatelessWidget {
  const FinanceCommitmentsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return GetBuilder<FinanceController>(
      id: 'finance',
      builder: (controller) {
        final commitments = controller.commitments;
        final snapshot = controller.snapshot;

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: colors.warning.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      size: AppIconSize.md,
                      color: colors.warning,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.financeCommitments.tr,
                          style: AppTextStyles.h6(colors),
                        ),
                        Text(
                          LocaleKeys.financeCommitmentsSubtitle.tr,
                          style: AppTextStyles.caption(colors),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showAddCommitmentDialog(context, controller),
                    icon: Icon(
                      Icons.add_rounded,
                      color: colors.primary,
                      size: AppIconSize.md,
                    ),
                    tooltip: LocaleKeys.financeAddCommitment.tr,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: colors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocaleKeys.financeSafeLiquidity.tr,
                              style: AppTextStyles.caption(colors),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              FinanceMonthSnapshot.format(snapshot.safeLiquidity),
                              style: AppTextStyles.h5(colors).copyWith(
                                color: snapshot.safeLiquidity >= 0
                                    ? colors.success
                                    : colors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 36,
                        width: 1,
                        color: colors.border,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocaleKeys.financeUnpaidCommitments.tr,
                              style: AppTextStyles.caption(colors),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              FinanceMonthSnapshot.format(snapshot.unpaidCommitments),
                              style: AppTextStyles.h6(colors).copyWith(
                                color: colors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (commitments.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Center(
                    child: Text(
                      LocaleKeys.financeCommitmentsSubtitle.tr,
                      style: AppTextStyles.caption(colors),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    for (final commitment in commitments)
                      _CommitmentTile(
                        commitment: commitment,
                        onToggle: () => controller.toggleCommitmentPaid(commitment),
                        onDelete: () => controller.deleteCommitment(commitment),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCommitmentDialog(
    BuildContext context,
    FinanceController controller,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _AddCommitmentDialog(controller: controller),
    );
  }
}

class _CommitmentTile extends StatelessWidget {
  const _CommitmentTile({
    required this.commitment,
    required this.onToggle,
    required this.onDelete,
  });

  final FinanceCommitment commitment;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: commitment.isPaid
                ? colors.border.withValues(alpha: 0.5)
                : colors.border,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Icon(
                    commitment.isPaid
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: commitment.isPaid
                        ? colors.success
                        : colors.textSecondary,
                    size: AppIconSize.md,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '${commitment.dueDay}',
                  style: AppTextStyles.caption(colors).copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      commitment.title,
                      style: AppTextStyles.body2(colors).copyWith(
                        decoration: commitment.isPaid
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: commitment.isPaid
                            ? colors.textSecondary
                            : colors.textPrimary,
                      ),
                    ),
                    if (commitment.note.isNotEmpty)
                      Text(
                        commitment.note,
                        style: AppTextStyles.caption(colors),
                      ),
                  ],
                ),
              ),
              Text(
                FinanceMonthSnapshot.format(commitment.amount),
                style: AppTextStyles.body2(colors).copyWith(
                  fontWeight: FontWeight.w700,
                  color: commitment.isPaid
                      ? colors.textSecondary
                      : colors.textPrimary,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: AppIconSize.sm,
                  color: colors.textSecondary.withValues(alpha: 0.6),
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddCommitmentDialog extends StatefulWidget {
  const _AddCommitmentDialog({required this.controller});

  final FinanceController controller;

  @override
  State<_AddCommitmentDialog> createState() => _AddCommitmentDialogState();
}

class _AddCommitmentDialogState extends State<_AddCommitmentDialog> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dueDayController = TextEditingController(text: '1');
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dueDayController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return Dialog(
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                LocaleKeys.financeAddCommitment.tr,
                style: AppTextStyles.h6(colors),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: LocaleKeys.financeCommitmentTitle.tr,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: LocaleKeys.financeAmount.tr,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _dueDayController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: LocaleKeys.financeDueDay.tr,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: LocaleKeys.financeNote.tr,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: LocaleKeys.financeAdd.tr,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final dueDay = int.tryParse(_dueDayController.text) ?? 1;

    if (title.isEmpty || amount <= 0) return;

    widget.controller.addCommitment(
      title: title,
      amount: amount,
      dueDay: dueDay.clamp(1, 31),
      note: _noteController.text.trim(),
    );
    Navigator.of(context).pop();
  }
}
