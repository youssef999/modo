import 'package:flutter/material.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';

/// Page heading: accent icon badge, bold title, subtitle, accent underline.
class AppPageTitle extends StatelessWidget {
  const AppPageTitle({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.accent,
    this.trailing,
    this.compact = false,
  });

  final String title;
  final IconData icon;
  final String? subtitle;
  final Color? accent;
  final Widget? trailing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final tone = accent ?? colors.primary;
    final badge = compact ? AppIconSize.xl + AppSpacing.sm : AppSpacing.xxl;

    return Row(
      children: [
        Container(
          width: badge,
          height: badge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [tone, tone.withValues(alpha: 0.72)],
            ),
            boxShadow: [
              BoxShadow(
                color: tone.withValues(alpha: 0.32),
                blurRadius: AppSpacing.md,
                offset: const Offset(0, AppSpacing.xs),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: colors.onPrimary,
            size: compact ? AppIconSize.md : AppIconSize.lg,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    (compact
                            ? AppTextStyles.h5(colors)
                            : AppTextStyles.h4(colors))
                        .copyWith(fontWeight: FontWeight.w800, height: 1.2),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Container(
                    width: AppSpacing.lg,
                    height: AppSpacing.xs,
                    decoration: BoxDecoration(
                      color: tone,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption(colors),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.sm),
          trailing!,
        ],
      ],
    );
  }
}
