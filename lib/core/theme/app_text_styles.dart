import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';

class AppFonts {
  AppFonts._();

  static const String cairo = 'Cairo';
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle _cairo({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    required Color color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: AppFonts.cairo,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle h1(AppPalette colors) {
    return _cairo(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 1.25,
      color: colors.textPrimary,
    );
  }

  static TextStyle h2(AppPalette colors) {
    return _cairo(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.28,
      color: colors.textPrimary,
    );
  }

  static TextStyle h3(AppPalette colors) {
    return _cairo(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: colors.textPrimary,
    );
  }

  static TextStyle h4(AppPalette colors) {
    return _cairo(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: colors.textPrimary,
    );
  }

  static TextStyle h5(AppPalette colors) {
    return _cairo(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: colors.textPrimary,
    );
  }

  static TextStyle h6(AppPalette colors) {
    return _cairo(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: colors.textPrimary,
    );
  }

  static TextStyle body1(AppPalette colors) {
    return _cairo(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: colors.textPrimary,
    );
  }

  static TextStyle body2(AppPalette colors) {
    return _cairo(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: colors.textSecondary,
    );
  }

  static TextStyle caption(AppPalette colors) {
    return _cairo(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: colors.textSecondary,
    );
  }

  /// Modo wordmark. Color is painted by a gradient shader, so it uses white.
  static TextStyle wordmark(double fontSize) {
    return _cairo(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      height: 1.05,
      letterSpacing: -0.04 * fontSize,
      color: AppColors.brandOnNavy,
    );
  }

  static TextStyle button(AppPalette colors) {
    return _cairo(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.2,
      color: colors.onPrimary,
    );
  }
}
