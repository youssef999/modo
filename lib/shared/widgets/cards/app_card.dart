import 'package:flutter/material.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_shadows.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding, this.gradient});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null ? colors.card : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: gradient == null
            ? Border.all(color: colors.border.withValues(alpha: 0.55))
            : null,
        boxShadow: AppShadows.card(colors),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Material(
          color: colors.card.withValues(alpha: 0),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ),
      ),
    );
  }
}
