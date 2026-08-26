import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/category_icons.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/finance/models/finance_category_role.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';
import 'package:life_daily_app/shared/widgets/inputs/app_icon_picker.dart';
import 'package:life_daily_app/shared/widgets/inputs/app_text_field.dart';
import 'package:life_daily_app/shared/widgets/layout/app_scaffold.dart';

class FinanceCategoryPage extends StatefulWidget {
  const FinanceCategoryPage({
    super.key,
    this.initialRole = FinanceCategoryRole.spend,
  });

  final FinanceCategoryRole initialRole;

  @override
  State<FinanceCategoryPage> createState() => _FinanceCategoryPageState();
}

class _FinanceCategoryPageState extends State<FinanceCategoryPage> {
  final _name = TextEditingController();
  late FinanceCategoryRole _role;
  String _iconKey = CategoryIcons.fallback;

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole;
    if (_role == FinanceCategoryRole.allocate) {
      _iconKey = 'wallet';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lockIncome = widget.initialRole == FinanceCategoryRole.income;
    return AppScaffold(
      title: LocaleKeys.addCategory.tr,
      bottomBar: AppButton(label: LocaleKeys.save.tr, onPressed: _save),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _name,
              label: LocaleKeys.financeCategoryName.tr,
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppIconPicker(
              selectedKey: _iconKey,
              onSelected: (key) => setState(() => _iconKey = key),
            ),
            if (!lockIncome) ...[
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _RoleChip(
                      label: LocaleKeys.financeRoleSpend.tr,
                      selected: _role == FinanceCategoryRole.spend,
                      onTap: () => setState(() {
                        _role = FinanceCategoryRole.spend;
                      }),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _RoleChip(
                      label: LocaleKeys.financeRoleAllocate.tr,
                      selected: _role == FinanceCategoryRole.allocate,
                      onTap: () => setState(() {
                        _role = FinanceCategoryRole.allocate;
                        if (_iconKey == CategoryIcons.fallback) {
                          _iconKey = 'wallet';
                        }
                      }),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final id = await Get.find<FinanceController>().addCategory(
      name,
      role: _role,
      iconKey: _iconKey,
    );
    AppNavigator.back(id);
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.12)
              : colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: selected ? colors.primary : colors.border),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.body2(
            colors,
          ).copyWith(color: selected ? colors.primary : colors.textPrimary),
        ),
      ),
    );
  }
}
