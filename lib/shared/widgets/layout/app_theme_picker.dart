import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/controllers/theme_controller.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/core/theme/app_palette.dart';
import 'package:life_daily_app/core/theme/app_theme_id.dart';

class AppThemePicker extends StatelessWidget {
  const AppThemePicker({super.key, this.compact = false});

  /// One row of color dots instead of a full list.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      id: 'theme',
      builder: (controller) {
        if (compact) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final id in AppThemeId.values)
                _ThemeDot(
                  palette: AppColors.forId(id),
                  label: _label(id),
                  selected: controller.themeId == id,
                  onTap: () => controller.setTheme(id),
                ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final id in AppThemeId.values) ...[
              _ThemeOption(
                id: id,
                label: _label(id),
                selected: controller.themeId == id,
                onTap: () => controller.setTheme(id),
              ),
              if (id != AppThemeId.values.last)
                const SizedBox(height: AppSpacing.sm),
            ],
          ],
        );
      },
    );
  }

  String _label(AppThemeId id) {
    return switch (id) {
      AppThemeId.light => LocaleKeys.themeLight.tr,
      AppThemeId.dark => LocaleKeys.themeDark.tr,
      AppThemeId.noirRed => LocaleKeys.themeNoirRed.tr,
      AppThemeId.sunYellow => LocaleKeys.themeSunYellow.tr,
      AppThemeId.blushPink => LocaleKeys.themeBlushPink.tr,
    };
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.id,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AppThemeId id;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final palette = AppColors.forId(id);
    return Material(
      color: colors.card.withValues(alpha: 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          decoration: BoxDecoration(
            color: selected
                ? colors.primary.withValues(alpha: 0.08)
                : colors.card,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: selected ? colors.primary : colors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                _Swatch(palette: palette),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.body1(colors).copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: colors.primary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeDot extends StatelessWidget {
  const _ThemeDot({
    required this.palette,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AppPalette palette;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(AppSpacing.xs / 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? colors.primary
                    : colors.card.withValues(alpha: 0),
                width: 2,
              ),
            ),
            child: SizedBox(
              width: AppSpacing.xl,
              height: AppSpacing.xl,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: palette.border),
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    stops: const [0.5, 0.5],
                    colors: [palette.background, palette.primary],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.xxl,
      height: AppSpacing.lg,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: palette.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Row(
            children: [
              Expanded(child: ColoredBox(color: palette.background)),
              Expanded(child: ColoredBox(color: palette.primary)),
            ],
          ),
        ),
      ),
    );
  }
}
