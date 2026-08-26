import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';

class AppNavBar extends StatelessWidget implements PreferredSizeWidget {
  const AppNavBar({
    super.key,
    required this.title,
    this.actions,
    this.onBack,
    this.showBack = true,
  });

  final String title;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final bool showBack;

  static const double height = 44;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final canPop = Navigator.canPop(context);
    final showLeading = showBack && (onBack != null || canPop);

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colors.background,
      surfaceTintColor: colors.background,
      centerTitle: true,
      automaticallyImplyLeading: false,
      toolbarHeight: height,
      leadingWidth: AppSpacing.xxl + AppSpacing.sm,
      title: Text(
        title,
        style: AppTextStyles.h6(colors).copyWith(fontWeight: FontWeight.w600),
      ),
      leading: showLeading
          ? Align(
              alignment: AlignmentDirectional.centerStart,
              child: _BackButton(onPressed: onBack ?? Get.back),
            )
          : null,
      actions: [
        ...?actions,
        if (actions == null || actions!.isEmpty)
          const SizedBox(width: AppSpacing.xxl + AppSpacing.sm),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Divider(
          height: 0.5,
          thickness: 0.5,
          color: colors.border.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Material(
      color: colors.card.withValues(alpha: 0),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: AppSpacing.md,
            end: AppSpacing.sm,
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: AppIconSize.md,
            color: colors.primary,
          ),
        ),
      ),
    );
  }
}
