import 'package:flutter/material.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.autofocus = false,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.keyboardType,
    this.style,
    this.textAlign = TextAlign.start,
    this.focusNode,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextStyle? style;
  final TextAlign textAlign;
  final FocusNode? focusNode;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      autofocus: autofocus,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      keyboardType: keyboardType,
      textAlign: textAlign,
      focusNode: focusNode,
      style: style ?? AppTextStyles.body1(colors),
      cursorColor: colors.primary,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.body2(colors),
        filled: true,
        fillColor: colors.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.primary),
        ),
        contentPadding: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }
}
