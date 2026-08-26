import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';
import 'package:life_daily_app/shared/widgets/inputs/app_text_field.dart';

class FolderNameSheet {
  FolderNameSheet._();

  static Future<String?> show(
    BuildContext context, {
    required String title,
    String initial = '',
  }) {
    final colors = context.appPalette;
    return Get.dialog<String>(
      _FolderNameForm(title: title, initial: initial),
      barrierDismissible: true,
      barrierColor: colors.textPrimary.withValues(alpha: 0.45),
    );
  }
}

class _FolderNameForm extends StatefulWidget {
  const _FolderNameForm({required this.title, required this.initial});

  final String title;
  final String initial;

  @override
  State<_FolderNameForm> createState() => _FolderNameFormState();
}

class _FolderNameFormState extends State<_FolderNameForm> {
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return Dialog(
      backgroundColor: colors.card.withValues(alpha: 0),
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: keyboard > 0 ? keyboard * 0.35 : 0),
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.title, style: AppTextStyles.h5(colors)),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _name,
                label: LocaleKeys.folderName.tr,
                autofocus: true,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(label: LocaleKeys.save.tr, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty || name.length > 40) return;
    Get.back(result: name);
  }
}

class FolderGridCard extends StatelessWidget {
  const FolderGridCard({
    super.key,
    required this.title,
    required this.count,
    required this.previews,
    required this.onTap,
    required this.onLongPress,
  });

  final String title;
  final int count;
  final List<String> previews;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.h6(colors)),
            const SizedBox(height: AppSpacing.xs),
            Text('$count', style: AppTextStyles.caption(colors)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final preview in previews)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: colors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      child: Text(
                        preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption(colors),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
