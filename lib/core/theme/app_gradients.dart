import 'package:flutter/material.dart';

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
}
