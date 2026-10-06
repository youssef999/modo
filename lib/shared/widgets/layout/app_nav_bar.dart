import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';

/// App bar for pushed pages: back button, bold title with an accent
/// underline, and optional actions.
class AppNavBar extends StatelessWidget implements PreferredSizeWidget {
  const AppNavBar({
    super.key,
    required this.title,
    this.actions,
    this.onBack,
    this.showBack = true,
  });

  final String title;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final bool showBack;

  static const double height = 64;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final canPop = Navigator.canPop(context);
    final showLeading = showBack && (onBack != null || canPop);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.45),
            blurRadius: AppSpacing.md,
            offset: const Offset(0, AppSpacing.xs),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                if (showLeading) ...[
                  _BackButton(onPressed: onBack ?? Get.back),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h5(
                          colors,
                        ).copyWith(fontWeight: FontWeight.w800, height: 1.2),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        width: AppSpacing.lg,
                        height: AppSpacing.xs,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                      ),
                    ],
                  ),
                ),
                ...?actions,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Material(
      color: colors.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: SizedBox(
          width: AppSpacing.xl + AppSpacing.sm,
          height: AppSpacing.xl + AppSpacing.sm,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: AppIconSize.sm,
            color: colors.primary,
          ),
        ),
      ),
    );
  }
}
