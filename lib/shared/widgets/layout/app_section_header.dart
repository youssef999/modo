import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.onViewAll,
    this.totalCount,
    this.previewLimit = 3,
  });

  final String title;
  final VoidCallback? onViewAll;
  final int? totalCount;
  final int previewLimit;

  bool get _showViewAll {
    if (onViewAll == null || totalCount == null) return false;
    return totalCount! > previewLimit;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Row(
      children: [
        Expanded(
          child: Text(title, style: AppTextStyles.h6(colors)),
        ),
        if (_showViewAll)
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              LocaleKeys.viewAll.tr,
              style: AppTextStyles.caption(colors).copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
