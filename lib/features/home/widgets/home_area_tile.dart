import 'package:flutter/material.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';

class HomeAreaTile extends StatelessWidget {
  const HomeAreaTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return AppCard(
      padding: EdgeInsets.zero,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(icon, size: AppIconSize.lg, color: colors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.h6(colors)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(subtitle, style: AppTextStyles.caption(colors)),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: AppIconSize.md,
                color: colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
