import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_gradients.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/shell/controllers/shell_controller.dart';

class AppShellBottomChrome extends StatelessWidget {
  const AppShellBottomChrome({super.key});

  @override
  Widget build(BuildContext context) {
    final barHeight = AppSpacing.navBar;
    final fabSize = AppSpacing.fab;
    final bottomGap =
        MediaQuery.viewPaddingOf(context).bottom + AppSpacing.navLift;
    final sideGap = AppSpacing.lg;

    return SizedBox(
      height: barHeight + bottomGap + (fabSize / 2),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: sideGap,
            right: sideGap,
            bottom: bottomGap,
            height: barHeight,
            child: const _GlassBar(),
          ),
          Positioned(
            bottom: bottomGap + (barHeight / 2) - (fabSize / 2),
            child: const AppNavFab(),
          ),
        ],
      ),
    );
  }
}

class _GlassBar extends StatelessWidget {
  const _GlassBar();

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final fabSize = AppSpacing.fab;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppSpacing.lg, sigmaY: AppSpacing.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.navBar.withValues(alpha: 0.52),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: colors.onPrimary.withValues(alpha: 0.22)),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.28),
                blurRadius: AppSpacing.xl,
                offset: const Offset(0, AppSpacing.sm),
              ),
            ],
          ),
          child: GetBuilder<ShellController>(
            id: 'shell',
            builder: (controller) {
              return Row(
                children: [
                  for (final item in controller.leftItems)
                    _NavIcon(
                      item: item,
                      selected: controller.sectionIndex == item.sectionIndex,
                    ),
                  SizedBox(width: fabSize),
                  for (final item in controller.rightItems)
                    _NavIcon(
                      item: item,
                      selected:
                          !item.opensPlan &&
                          controller.sectionIndex == item.sectionIndex,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class AppNavFab extends StatelessWidget {
  const AppNavFab({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return SizedBox(
      width: AppSpacing.fab,
      height: AppSpacing.fab,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppSpacing.sm,
            sigmaY: AppSpacing.sm,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.primary(colors),
              border: Border.all(
                color: colors.onPrimary.withValues(alpha: 0.28),
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow,
                  blurRadius: AppSpacing.lg,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: colors.card.withValues(alpha: 0),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Get.find<ShellController>().onFab(),
                child: Icon(
                  Icons.add_rounded,
                  color: colors.onPrimary,
                  size: AppIconSize.xl,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.item, required this.selected});

  final ShellNavItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Get.find<ShellController>().selectSection(
          item.sectionIndex,
          opensPlan: item.opensPlan,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: selected
                    ? colors.primary.withValues(alpha: 0.16)
                    : colors.card.withValues(alpha: 0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                size: AppIconSize.lg,
                color: selected ? colors.primary : colors.textSecondary,
              ),
            ),
            Text(
              item.labelKey.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption(colors).copyWith(
                color: selected ? colors.primary : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
