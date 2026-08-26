import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/category_icons.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';
import 'package:life_daily_app/shared/widgets/inputs/app_icon_picker.dart';
import 'package:life_daily_app/shared/widgets/inputs/app_text_field.dart';
import 'package:life_daily_app/shared/widgets/layout/app_scaffold.dart';

class GoalCategoryPage extends StatefulWidget {
  const GoalCategoryPage({super.key});

  @override
  State<GoalCategoryPage> createState() => _GoalCategoryPageState();
}

class _GoalCategoryPageState extends State<GoalCategoryPage> {
  final _name = TextEditingController();
  String _iconKey = CategoryIcons.fallback;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              label: LocaleKeys.goalCategory.tr,
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppIconPicker(
              selectedKey: _iconKey,
              onSelected: (key) => setState(() => _iconKey = key),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final id = await Get.find<GoalsController>().addCategory(
      name,
      iconKey: _iconKey,
    );
    AppNavigator.back(id);
  }
}
