import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';
import 'package:life_daily_app/shared/widgets/inputs/app_text_field.dart';
import 'package:life_daily_app/shared/widgets/layout/app_scaffold.dart';

class FinanceMonthPlanPage extends StatefulWidget {
  const FinanceMonthPlanPage({super.key});

  @override
  State<FinanceMonthPlanPage> createState() => _FinanceMonthPlanPageState();
}

class _FinanceMonthPlanPageState extends State<FinanceMonthPlanPage> {
  late final TextEditingController _salary;
  late final TextEditingController _budget;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<FinanceController>();
    final plan = controller.planFor(controller.month);
    _salary = TextEditingController(
      text: plan.expectedSalary > 0
          ? FinanceController.formatAmount(plan.expectedSalary)
          : '',
    );
    _budget = TextEditingController(
      text: plan.spendBudget > 0
          ? FinanceController.formatAmount(plan.spendBudget)
          : '',
    );
  }

  @override
  void dispose() {
    _salary.dispose();
    _budget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final controller = Get.find<FinanceController>();
    final monthLabel = MaterialLocalizations.of(
      context,
    ).formatMonthYear(controller.month);
    return AppScaffold(
      title: LocaleKeys.financeMonthPlan.tr,
      bottomBar: AppButton(label: LocaleKeys.save.tr, onPressed: _save),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(monthLabel, style: AppTextStyles.h6(colors)),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _salary,
            label: LocaleKeys.financeExpectedSalary.tr,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _budget,
            label: LocaleKeys.financeSpendBudget.tr,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final salary = double.tryParse(_salary.text.replaceAll(',', '.')) ?? 0;
    final budget = double.tryParse(_budget.text.replaceAll(',', '.')) ?? 0;
    await Get.find<FinanceController>().saveMonthPlan(
      expectedSalary: salary,
      spendBudget: budget,
    );
    Get.back();
  }
}
