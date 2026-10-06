import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';
import 'app_theme_id.dart';

class AppTheme {
  AppTheme._();

  static ThemeData forId(AppThemeId id) {
    return _build(
      AppColors.forId(id),
      id.isDark ? Brightness.dark : Brightness.light,
    );
  }

  static ThemeData get light => forId(AppThemeId.light);

  static ThemeData get dark => forId(AppThemeId.dark);

  static ThemeData _build(AppPalette palette, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      secondary: palette.secondary,
      onSecondary: palette.onPrimary,
      error: palette.error,
      onError: palette.onPrimary,
      surface: palette.surface,
      onSurface: palette.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      dividerColor: palette.divider,
      fontFamily: AppFonts.cairo,
      extensions: <ThemeExtension<dynamic>>[palette],
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1(palette),
        displayMedium: AppTextStyles.h2(palette),
        displaySmall: AppTextStyles.h3(palette),
        headlineMedium: AppTextStyles.h4(palette),
        headlineSmall: AppTextStyles.h5(palette),
        titleLarge: AppTextStyles.h6(palette),
        bodyLarge: AppTextStyles.body1(palette),
        bodyMedium: AppTextStyles.body2(palette),
        bodySmall: AppTextStyles.caption(palette),
        labelLarge: AppTextStyles.button(palette),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: palette.background,
        surfaceTintColor: palette.background,
        foregroundColor: palette.textPrimary,
        centerTitle: true,
        toolbarHeight: 44,
        titleTextStyle: AppTextStyles.h6(
          palette,
        ).copyWith(fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: palette.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      dividerTheme: DividerThemeData(color: palette.divider, space: 1),
      iconTheme: IconThemeData(color: palette.primary),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: palette.surface,
        headerForegroundColor: palette.textPrimary,
      ),
    );
  }
}
