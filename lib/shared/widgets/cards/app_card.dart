import 'package:flutter/material.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    Widget card = DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null ? colors.card : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: gradient == null
            ? Border.all(color: colors.border.withValues(alpha: 0.55))
            : null,
        boxShadow: [
          // Soft ambient shadow with negative spread so it stays gracefully under the card
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.12),
            blurRadius: 16,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
          // Subtle neutral depth shadow for crisp physical grounding
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
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

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    return card;
  }
}
