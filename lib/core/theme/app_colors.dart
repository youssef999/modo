import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_theme_id.dart';

class AppColors {
  AppColors._();

  static AppPalette forId(AppThemeId id) {
    return switch (id) {
      AppThemeId.light => light,
      AppThemeId.dark => dark,
      AppThemeId.noirRed => noirRed,
      AppThemeId.sunYellow => sunYellow,
      AppThemeId.blushPink => blushPink,
    };
  }

  static const light = AppPalette(
    primary: Color(0xFF06B6D4),
    primaryLight: Color(0xFF67E8F9),
    primaryDark: Color(0xFF0E7490),
    secondary: Color(0xFF38BDF8),
    secondaryLight: Color(0xFF7DD3FC),
    background: Color(0xFFF3FBFD),
    surface: Color(0xFFF7FDFE),
    card: Color(0xFFFFFFFF),
    navBar: Color(0xFFEEF9FC),
    success: Color(0xFF3DDC97),
    warning: Color(0xFFFFC857),
    error: Color(0xFFFF6B6B),
    info: Color(0xFF22D3EE),
    textPrimary: Color(0xFF0F3A45),
    textSecondary: Color(0xFF5A7A84),
    textDisabled: Color(0xFF9BB4BB),
    border: Color(0xFFD7EEF4),
    divider: Color(0xFFE8F6F9),
    shadow: Color(0x3306B6D4),
    onPrimary: Color(0xFFFFFFFF),
  );

  static const dark = AppPalette(
    primary: Color(0xFF22D3EE),
    primaryLight: Color(0xFF67E8F9),
    primaryDark: Color(0xFF06B6D4),
    secondary: Color(0xFF38BDF8),
    secondaryLight: Color(0xFF7DD3FC),
    background: Color(0xFF082028),
    surface: Color(0xFF0E2C36),
    card: Color(0xFF13343F),
    navBar: Color(0xFF0C2831),
    success: Color(0xFF3DDC97),
    warning: Color(0xFFFFC857),
    error: Color(0xFFFF6B6B),
    info: Color(0xFF67E8F9),
    textPrimary: Color(0xFFF3FBFD),
    textSecondary: Color(0xFF8AADB6),
    textDisabled: Color(0xFF4D6B73),
    border: Color(0xFF1E4550),
    divider: Color(0xFF18404A),
    shadow: Color(0x66082028),
    onPrimary: Color(0xFF082028),
  );

  static const noirRed = AppPalette(
    primary: Color(0xFFE63946),
    primaryLight: Color(0xFFFF6B6B),
    primaryDark: Color(0xFFC1121F),
    secondary: Color(0xFFFF5252),
    secondaryLight: Color(0xFFFF8A80),
    background: Color(0xFF0A0A0A),
    surface: Color(0xFF141414),
    card: Color(0xFF1A1A1A),
    navBar: Color(0xFF101010),
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFBBF24),
    error: Color(0xFFFF4757),
    info: Color(0xFFFF6B6B),
    textPrimary: Color(0xFFF5F5F5),
    textSecondary: Color(0xFFA3A3A3),
    textDisabled: Color(0xFF525252),
    border: Color(0xFF2E2E2E),
    divider: Color(0xFF242424),
    shadow: Color(0x66E63946),
    onPrimary: Color(0xFFFFFFFF),
  );

  static const sunYellow = AppPalette(
    primary: Color(0xFFF5A623),
    primaryLight: Color(0xFFFFD166),
    primaryDark: Color(0xFFE09F00),
    secondary: Color(0xFFFFC947),
    secondaryLight: Color(0xFFFFE08A),
    background: Color(0xFFFFFCF5),
    surface: Color(0xFFFFF9E8),
    card: Color(0xFFFFFFFF),
    navBar: Color(0xFFFFF6DC),
    success: Color(0xFF22C55E),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    info: Color(0xFFFBBF24),
    textPrimary: Color(0xFF1A1400),
    textSecondary: Color(0xFF7A6520),
    textDisabled: Color(0xFFB8A574),
    border: Color(0xFFF0E4C8),
    divider: Color(0xFFF7EFD8),
    shadow: Color(0x33F5A623),
    onPrimary: Color(0xFF1A1400),
  );

  static const blushPink = AppPalette(
    primary: Color(0xFFEC4899),
    primaryLight: Color(0xFFF9A8D4),
    primaryDark: Color(0xFFDB2777),
    secondary: Color(0xFFF472B6),
    secondaryLight: Color(0xFFFBCFE8),
    background: Color(0xFFFFF5F8),
    surface: Color(0xFFFFEBF1),
    card: Color(0xFFFFFFFF),
    navBar: Color(0xFFFFE8F0),
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    error: Color(0xFFF87171),
    info: Color(0xFFF472B6),
    textPrimary: Color(0xFF4A1942),
    textSecondary: Color(0xFF9D7189),
    textDisabled: Color(0xFFC4A3B5),
    border: Color(0xFFF5D0E0),
    divider: Color(0xFFFCE7F3),
    shadow: Color(0x33EC4899),
    onPrimary: Color(0xFFFFFFFF),
  );
}

extension AppPaletteX on BuildContext {
  AppPalette get appPalette {
    return Theme.of(this).extension<AppPalette>() ?? AppColors.light;
  }
}
