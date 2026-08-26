import 'package:flutter/material.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final enabled = onPressed != null;
    final Color background;
    final Color foreground;
    final BorderSide? border;
    switch (variant) {
      case AppButtonVariant.primary:
        background = colors.primary;
        foreground = colors.onPrimary;
        border = null;
      case AppButtonVariant.secondary:
        background = colors.card;
        foreground = colors.textPrimary;
        border = BorderSide(color: colors.border);
      case AppButtonVariant.danger:
        background = colors.error;
        foreground = colors.onPrimary;
        border = null;
    }

    return SizedBox(
      height: 50,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: border == null ? null : Border.fromBorderSide(border),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(
                    label,
                    style: AppTextStyles.button(
                      colors,
                    ).copyWith(color: foreground, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
