import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_spacing.dart';

class AppShadows {
  AppShadows._();

  /// Soft shadow shared by every card surface.
  static List<BoxShadow> card(AppPalette colors) {
    return [
      BoxShadow(
        color: colors.shadow.withValues(alpha: 0.05),
        blurRadius: AppSpacing.sm + AppSpacing.xs,
        offset: const Offset(0, AppSpacing.xs),
      ),
    ];
  }
}
