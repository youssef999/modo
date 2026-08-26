import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/core/theme/category_icons.dart';

class AppIconPicker extends StatelessWidget {
  const AppIconPicker({
    super.key,
    required this.selectedKey,
    required this.onSelected,
  });

  final String selectedKey;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(LocaleKeys.categoryIcon.tr, style: AppTextStyles.caption(colors)),
        const SizedBox(height: AppSpacing.sm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: CategoryIcons.keys.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final key = CategoryIcons.keys[index];
            final selected = key == selectedKey;
            final tint = CategoryIcons.color(key, colors);
            return GestureDetector(
              onTap: () => onSelected(key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                decoration: BoxDecoration(
                  color: selected
                      ? tint.withValues(alpha: 0.16)
                      : colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: selected ? tint : colors.border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Icon(
                  CategoryIcons.of(key),
                  color: selected ? tint : colors.textSecondary,
                  size: AppIconSize.lg,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
