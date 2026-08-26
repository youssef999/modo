import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/finance/models/finance_category.dart';
import 'package:life_daily_app/features/finance/models/finance_category_role.dart';
import 'package:life_daily_app/features/finance/models/finance_entry.dart';
import 'package:life_daily_app/features/finance/widgets/finance_numpad.dart';
import 'package:life_daily_app/features/finance/widgets/finance_segmented.dart';
import 'package:life_daily_app/shared/widgets/inputs/app_text_field.dart';
import 'package:life_daily_app/shared/widgets/layout/app_scaffold.dart';

class FinanceEntryPage extends StatefulWidget {
  const FinanceEntryPage({super.key, required this.kind});

  final FinanceKind kind;

  @override
  State<FinanceEntryPage> createState() => _FinanceEntryPageState();
}

class _FinanceEntryPageState extends State<FinanceEntryPage> {
  final _note = TextEditingController();
  final _noteFocus = FocusNode();
  late bool _isIncome;
  late DateTime _date;
  late String _categoryId;
  String _buffer = '0';
  double _stored = 0;
  String? _op;
  bool _noteFocused = false;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<FinanceController>();
    _isIncome = widget.kind != FinanceKind.expense;
    _date = DateTime.now();
    _categoryId = _defaultCategoryId(controller);
    _noteFocus.addListener(() {
      setState(() => _noteFocused = _noteFocus.hasFocus);
    });
  }

  String _defaultCategoryId(FinanceController controller) {
    final pool = _isIncome
        ? controller.incomeCategories
        : controller.spendCategories;
    if (controller.selectedCategoryId != null &&
        pool.any((item) => item.id == controller.selectedCategoryId)) {
      return controller.selectedCategoryId!;
    }
    if (_isIncome) {
      final salary = pool.where((item) => item.id == 'salary');
      if (salary.isNotEmpty) return salary.first.id;
    }
    return pool.isEmpty ? '' : pool.first.id;
  }

  @override
  void dispose() {
    _note.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GetBuilder<FinanceController>(
      id: 'finance',
      builder: (controller) {
        final categories = _isIncome
            ? controller.incomeCategories
            : controller.spendCategories;
        return AppScaffold(
          title: LocaleKeys.financeAdd.tr,
          body: Column(
            children: [
              FinanceSegmented(
                leftLabel: LocaleKeys.financeExpenses.tr,
                rightLabel: LocaleKeys.financeIncome.tr,
                isLeft: !_isIncome,
                onLeft: () => setState(() {
                  _isIncome = false;
                  _categoryId = _defaultCategoryId(controller);
                }),
                onRight: () => setState(() {
                  _isIncome = true;
                  _categoryId = _defaultCategoryId(controller);
                }),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: GridView.builder(
                  itemCount: categories.length + 1,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, index) {
                    if (index == categories.length) {
                      return _AddCategoryCell(
                        onTap: () async {
                          final id = await AppNavigator.toFinanceCategory(
                            role: _isIncome
                                ? FinanceCategoryRole.income
                                : FinanceCategoryRole.spend,
                          );
                          if (id == null || id.isEmpty) return;
                          setState(() => _categoryId = id);
                        },
                      );
                    }
                    final category = categories[index];
                    return _CategoryCell(
                      category: category,
                      label: controller.categoryLabel(category),
                      selected: category.id == _categoryId,
                      onTap: () => setState(() => _categoryId = category.id),
                    );
                  },
                ),
              ),
              GestureDetector(
                onTap: _noteFocus.unfocus,
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(_buffer, style: AppTextStyles.h1(colors)),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _note,
                label: LocaleKeys.financeNote.tr,
                focusNode: _noteFocus,
              ),
              SizedBox(
                height: _noteFocused ? AppSpacing.lg : AppSpacing.sm,
              ),
              if (!_noteFocused)
                FinanceNumpad(
                  dateLabel: financeTodayLabel(_date),
                  onDigit: _appendDigit,
                  onDot: _appendDot,
                  onBackspace: _backspace,
                  onDate: _pickDate,
                  onPlus: () => _applyOp('+'),
                  onMinus: () => _applyOp('-'),
                  onSubmit: _save,
                ),
              SizedBox(
                height: _noteFocused
                    ? AppSpacing.md
                    : AppSpacing.md + MediaQuery.paddingOf(context).bottom,
              ),
            ],
          ),
        );
      },
    );
  }

  void _appendDigit(String digit) {
    setState(() {
      if (_buffer == '0') {
        _buffer = digit;
      } else {
        _buffer += digit;
      }
    });
  }

  void _appendDot() {
    if (_buffer.contains('.')) return;
    setState(() => _buffer = '$_buffer.');
  }

  void _backspace() {
    setState(() {
      if (_buffer.length <= 1) {
        _buffer = '0';
      } else {
        _buffer = _buffer.substring(0, _buffer.length - 1);
      }
    });
  }

  void _applyOp(String op) {
    final current = double.tryParse(_buffer) ?? 0;
    setState(() {
      if (_op == null) {
        _stored = current;
      } else {
        _stored = _op == '+' ? _stored + current : _stored - current;
      }
      _op = op;
      _buffer = '0';
    });
  }

  double _resolvedAmount() {
    final current = double.tryParse(_buffer) ?? 0;
    if (_op == '+') return _stored + current;
    if (_op == '-') return _stored - current;
    return current;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  Future<void> _save() async {
    final amount = _resolvedAmount();
    if (amount <= 0 || _categoryId.isEmpty) return;
    final controller = Get.find<FinanceController>();
    if (_isIncome) {
      await controller.addIncome(
        amount: amount,
        categoryId: _categoryId,
        occurredAt: _date,
        note: _note.text,
      );
    } else {
      await controller.addExpense(
        amount: amount,
        categoryId: _categoryId,
        occurredAt: _date,
        note: _note.text,
      );
    }
    Get.back();
  }
}

class _CategoryCell extends StatelessWidget {
  const _CategoryCell({
    required this.category,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final FinanceCategory category;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final tint = category.color(colors);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: AppSpacing.xxl + AppSpacing.sm,
            height: AppSpacing.xxl + AppSpacing.sm,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? colors.primary : colors.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Icon(category.icon, color: tint, size: AppIconSize.lg),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(colors),
          ),
        ],
      ),
    );
  }
}

class _AddCategoryCell extends StatelessWidget {
  const _AddCategoryCell({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: AppSpacing.xxl + AppSpacing.sm,
            height: AppSpacing.xxl + AppSpacing.sm,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colors.primary),
            ),
            child: Icon(
              Icons.add_rounded,
              color: colors.primary,
              size: AppIconSize.lg,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            LocaleKeys.addCategory.tr,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(colors),
          ),
        ],
      ),
    );
  }
}
