import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_palette.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/finance/models/finance_category.dart';
import 'package:life_daily_app/features/finance/models/finance_category_role.dart';
import 'package:life_daily_app/features/finance/models/finance_entry.dart';
import 'package:life_daily_app/features/finance/widgets/finance_segmented.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';
import 'package:life_daily_app/shared/widgets/inputs/app_category_sheet.dart';

class AddFinanceEntryDialog extends StatefulWidget {
  const AddFinanceEntryDialog({
    super.key,
    this.initialKind = FinanceKind.expense,
  });

  final FinanceKind initialKind;

  static Future<void> show(
    BuildContext context, {
    FinanceKind kind = FinanceKind.expense,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AddFinanceEntryDialog(initialKind: kind),
    );
  }

  @override
  State<AddFinanceEntryDialog> createState() => _AddFinanceEntryDialogState();
}

class _AddFinanceEntryDialogState extends State<AddFinanceEntryDialog> {
  late bool _isIncome;
  late DateTime _date;
  String? _categoryId;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isIncome = widget.initialKind != FinanceKind.expense;
    final controller = Get.find<FinanceController>();
    _date = controller.defaultEntryDate();
    _categoryId = _resolveDefaultCategory(controller);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _resolveDefaultCategory(FinanceController controller) {
    final pool = _isIncome
        ? controller.incomeCategories
        : controller.spendCategories;
    if (pool.isEmpty) return '';
    return pool.first.id;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return Dialog(
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: GetBuilder<FinanceController>(
            id: 'finance',
            builder: (controller) {
              final categories = _isIncome
                  ? controller.incomeCategories
                  : controller.spendCategories;

              if (_categoryId == null ||
                  !categories.any((c) => c.id == _categoryId)) {
                _categoryId = _resolveDefaultCategory(controller);
              }

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FinanceSegmented(
                      leftLabel: LocaleKeys.financeExpenses.tr,
                      rightLabel: LocaleKeys.financeIncome.tr,
                      isLeft: !_isIncome,
                      onLeft: () => setState(() {
                        _isIncome = false;
                        _categoryId = _resolveDefaultCategory(controller);
                      }),
                      onRight: () => setState(() {
                        _isIncome = true;
                        _categoryId = _resolveDefaultCategory(controller);
                      }),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _amountController,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: AppTextStyles.h4(colors),
                      decoration: InputDecoration(
                        labelText: LocaleKeys.financeAmount.tr,
                        prefixIcon: Icon(
                          _isIncome
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: _isIncome ? colors.success : colors.primary,
                        ),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        if (categories.isNotEmpty)
                          Expanded(
                            child: _categoryDropdown(
                              categories,
                              controller,
                              colors,
                            ),
                          )
                        else
                          Expanded(
                            child: Text(
                              LocaleKeys.addCategory.tr,
                              style: AppTextStyles.body2(colors),
                            ),
                          ),
                        const SizedBox(width: AppSpacing.xs),
                        IconButton.filledTonal(
                          tooltip: LocaleKeys.addCategory.tr,
                          onPressed: () => _addCategory(controller),
                          icon: Icon(
                            Icons.add_rounded,
                            size: AppIconSize.md,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: colors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              color: colors.primary,
                              size: 22,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    LocaleKeys.goalDate.tr,
                                    style: AppTextStyles.caption(colors),
                                  ),
                                  Text(
                                    MaterialLocalizations.of(
                                      context,
                                    ).formatMediumDate(_date),
                                    style: AppTextStyles.body1(
                                      colors,
                                    ).copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                              ),
                              child: Text(
                                LocaleKeys.editGoal.tr,
                                style: AppTextStyles.caption(colors).copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: LocaleKeys.financeNote.tr,
                        hintText: LocaleKeys.financeNote.tr,
                        prefixIcon: const Icon(Icons.edit_note_rounded),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: LocaleKeys.financeAdd.tr,
                      onPressed: _save,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _categoryDropdown(
    List<FinanceCategory> categories,
    FinanceController controller,
    AppPalette colors,
  ) {
    return DropdownButtonFormField<String>(
      key: ValueKey(_categoryId),
      initialValue: _categoryId,
      isExpanded: true,
      items: [
        for (final cat in categories)
          DropdownMenuItem(
            value: cat.id,
            child: Row(
              children: [
                Icon(cat.icon, size: AppIconSize.md, color: cat.color(colors)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    controller.categoryLabel(cat),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body2(colors),
                  ),
                ),
              ],
            ),
          ),
      ],
      onChanged: (val) {
        if (val != null) setState(() => _categoryId = val);
      },
      decoration: InputDecoration(
        labelText: LocaleKeys.goalCategory.tr,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }

  Future<void> _addCategory(FinanceController controller) async {
    final draft = await AppCategorySheet.show(context);
    if (draft == null) return;
    final id = await controller.addCategory(
      draft.name,
      role: _isIncome ? FinanceCategoryRole.income : FinanceCategoryRole.spend,
      iconKey: draft.iconKey,
      select: false,
    );
    if (id != null && mounted) setState(() => _categoryId = id);
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0 || _categoryId == null || _categoryId!.isEmpty) return;

    final controller = Get.find<FinanceController>();
    if (_isIncome) {
      await controller.addIncome(
        amount: amount,
        categoryId: _categoryId!,
        occurredAt: _date,
        note: _noteController.text.trim(),
      );
    } else {
      await controller.addExpense(
        amount: amount,
        categoryId: _categoryId!,
        occurredAt: _date,
        note: _noteController.text.trim(),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }
}
