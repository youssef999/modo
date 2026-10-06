import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/breakpoints.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/core/theme/category_icons.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';
import 'package:life_daily_app/shared/widgets/inputs/app_icon_picker.dart';
import 'package:life_daily_app/shared/widgets/inputs/app_text_field.dart';

typedef AppCategoryDraft = ({String name, String iconKey});

/// Small "new section" form (name + icon). Returns null when dismissed.
class AppCategorySheet extends StatefulWidget {
  const AppCategorySheet({super.key, this.initialIconKey});

  final String? initialIconKey;

  static const double _dialogMaxWidth = 420;

  static Future<AppCategoryDraft?> show(
    BuildContext context, {
    String? initialIconKey,
  }) {
    final colors = context.appPalette;
    final sheet = AppCategorySheet(initialIconKey: initialIconKey);
    if (MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop) {
      return showDialog<AppCategoryDraft>(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _dialogMaxWidth),
            child: sheet,
          ),
        ),
      );
    }
    return showModalBottomSheet<AppCategoryDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: sheet,
      ),
    );
  }

  @override
  State<AppCategorySheet> createState() => _AppCategorySheetState();
}

class _AppCategorySheetState extends State<AppCategorySheet> {
  final _name = TextEditingController();
  late String _iconKey = widget.initialIconKey ?? CategoryIcons.fallback;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    Navigator.of(
      context,
    ).pop<AppCategoryDraft>((name: name, iconKey: _iconKey));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(LocaleKeys.addCategory.tr, style: AppTextStyles.h6(colors)),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _name,
            label: LocaleKeys.financeCategoryName.tr,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: AppSpacing.md),
          AppIconPicker(
            selectedKey: _iconKey,
            onSelected: (key) => setState(() => _iconKey = key),
          ),
          const SizedBox(height: AppSpacing.lg),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _name,
            builder: (context, value, _) => AppButton(
              label: LocaleKeys.save.tr,
              onPressed: value.text.trim().isEmpty ? null : _save,
            ),
          ),
        ],
      ),
    );
  }
}
