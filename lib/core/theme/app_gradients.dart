import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';

class AppGradients {
  AppGradients._();

  static LinearGradient primary(AppPalette colors) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [colors.primaryLight, colors.primary],
    );
  }

  static LinearGradient primaryHero(AppPalette colors) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [colors.primary, colors.secondary],
    );
  }

  static LinearGradient accent(AppPalette colors) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [colors.secondaryLight, colors.secondary],
    );
  }

  /// Blue to cyan to green, following the Modo logo ring.
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.brandBlue, AppColors.brandCyan, AppColors.brandGreen],
  );
}
