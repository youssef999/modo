import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/controllers/locale_controller.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/auth/controllers/auth_controller.dart';
import 'package:life_daily_app/features/auth/widgets/auth_dialog.dart';
import 'package:life_daily_app/features/finance/models/finance_entry.dart';
import 'package:life_daily_app/features/finance/pages/finance_page.dart';
import 'package:life_daily_app/features/goals/pages/goals_page.dart';
import 'package:life_daily_app/features/shell/controllers/shell_controller.dart';
import 'package:life_daily_app/features/shell/widgets/shell_area_style.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';
import 'package:life_daily_app/shared/widgets/layout/app_theme_picker.dart';

class WebShellLayout extends StatelessWidget {
  const WebShellLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return Scaffold(
      backgroundColor: colors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _WebSidebar(),
          VerticalDivider(width: 1, thickness: 1, color: colors.border),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _WebTopHeader(),
                Expanded(
                  child: GetBuilder<ShellController>(
                    id: 'shell',
                    builder: (controller) {
                      return IndexedStack(
                        index: controller.area.index,
                        children: const [
                          GoalsPage(embed: true),
                          FinancePage(embed: true),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WebSidebar extends StatelessWidget {
  const _WebSidebar();

  static const double sidebarWidth = 260.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return SizedBox(
      width: sidebarWidth,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.card,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        Icons.space_dashboard_rounded,
                        color: colors.primary,
                        size: AppIconSize.lg,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocaleKeys.appName.tr,
                            style: AppTextStyles.h6(colors).copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            LocaleKeys.homeSubtitle.tr,
                            style: AppTextStyles.caption(colors),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.md,
                  ),
                  children: [
                    GetBuilder<ShellController>(
                      id: 'shell',
                      builder: (controller) {
                        return Column(
                          children: [
                            _WebNavItem(
                              icon: Icons.flag_rounded,
                              label: LocaleKeys.webNavGoals.tr,
                              selected: controller.area == ShellArea.goals,
                              color: colors.primary,
                              onTap: () =>
                                  controller.selectArea(ShellArea.goals),
                            ),
                            if (controller.area == ShellArea.goals) ...[
                              _WebSubNavItem(
                                label: LocaleKeys.navList.tr,
                                selected: controller.sectionIndex == 0,
                                onTap: () => controller.selectSection(0),
                              ),
                              _WebSubNavItem(
                                label: LocaleKeys.navProgress.tr,
                                selected: controller.sectionIndex == 1,
                                onTap: () => controller.selectSection(1),
                              ),
                              _WebSubNavItem(
                                label: LocaleKeys.navFolders.tr,
                                selected: controller.sectionIndex == 2,
                                onTap: () => controller.selectSection(2),
                              ),
                              _WebSubNavItem(
                                label: LocaleKeys.navDone.tr,
                                selected: controller.sectionIndex == 3,
                                onTap: () => controller.selectSection(3),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.sm),
                            _WebNavItem(
                              icon: Icons.account_balance_wallet_rounded,
                              label: LocaleKeys.webNavFinance.tr,
                              selected: controller.area == ShellArea.finance,
                              color: colors.success,
                              onTap: () =>
                                  controller.selectArea(ShellArea.finance),
                            ),
                            if (controller.area == ShellArea.finance) ...[
                              _WebSubNavItem(
                                label: LocaleKeys.navActivity.tr,
                                selected: controller.sectionIndex == 0,
                                onTap: () => controller.selectSection(0),
                              ),
                              _WebSubNavItem(
                                label: LocaleKeys.financeCharts.tr,
                                selected: controller.sectionIndex == 1,
                                onTap: () => controller.selectSection(1),
                              ),
                              _WebSubNavItem(
                                label: LocaleKeys.financeReports.tr,
                                selected: controller.sectionIndex == 2,
                                onTap: () => controller.selectSection(2),
                              ),
                              _WebSubNavItem(
                                label: LocaleKeys.financeMonthPlan.tr,
                                selected: false,
                                onTap: () => AppNavigator.toMonthPlan(),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _WebSyncCard(),
                    const SizedBox(height: AppSpacing.md),
                    const AppThemePicker(),
                    const SizedBox(height: AppSpacing.sm),
                    GetBuilder<LocaleController>(
                      builder: (locale) {
                        return Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: LocaleKeys.english.tr,
                                variant: locale.isArabic
                                    ? AppButtonVariant.secondary
                                    : AppButtonVariant.primary,
                                onPressed: () =>
                                    locale.setLocale(const Locale('en', 'US')),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: AppButton(
                                label: LocaleKeys.arabic.tr,
                                variant: locale.isArabic
                                    ? AppButtonVariant.primary
                                    : AppButtonVariant.secondary,
                                onPressed: () =>
                                    locale.setLocale(const Locale('ar', 'SA')),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebNavItem extends StatefulWidget {
  const _WebNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_WebNavItem> createState() => _WebNavItemState();
}

class _WebNavItemState extends State<_WebNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: widget.selected
                ? widget.color.withValues(alpha: 0.15)
                : _hovered
                    ? colors.surface
                    : colors.card.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: widget.selected
                  ? widget.color.withValues(alpha: 0.3)
                  : colors.border.withValues(alpha: 0),
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: widget.selected ? widget.color : colors.textSecondary,
                size: AppIconSize.md,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.label,
                  style: AppTextStyles.body1(colors).copyWith(
                    fontWeight:
                        widget.selected ? FontWeight.w600 : FontWeight.w500,
                    color:
                        widget.selected ? widget.color : colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebSubNavItem extends StatefulWidget {
  const _WebSubNavItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_WebSubNavItem> createState() => _WebSubNavItemState();
}

class _WebSubNavItemState extends State<_WebSubNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: AppSpacing.xl,
            top: 2,
            bottom: 2,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: widget.selected
                  ? colors.primary.withValues(alpha: 0.1)
                  : _hovered
                      ? colors.surface
                      : colors.card.withValues(alpha: 0),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.selected
                        ? colors.primary
                        : colors.textSecondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    widget.label,
                    style: AppTextStyles.caption(colors).copyWith(
                      fontWeight:
                          widget.selected ? FontWeight.w600 : FontWeight.w400,
                      color: widget.selected
                          ? colors.primary
                          : colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WebSyncCard extends StatelessWidget {
  const _WebSyncCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return GetBuilder<AuthController>(
      id: 'auth',
      builder: (auth) {
        final isBackedUp = auth.isBackedUp;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => AuthDialog.show(context),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isBackedUp
                    ? colors.success.withValues(alpha: 0.1)
                    : colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isBackedUp
                      ? colors.success.withValues(alpha: 0.25)
                      : colors.border,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Row(
                  children: [
                    Icon(
                      isBackedUp
                          ? Icons.cloud_done_rounded
                          : Icons.cloud_off_rounded,
                      size: AppIconSize.md,
                      color: isBackedUp ? colors.success : colors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBackedUp
                                ? LocaleKeys.syncStatusSynced.tr
                                : LocaleKeys.syncStatusGuest.tr,
                            style: AppTextStyles.caption(colors).copyWith(
                              fontWeight: FontWeight.w600,
                              color: isBackedUp
                                  ? colors.success
                                  : colors.textPrimary,
                            ),
                          ),
                          Text(
                            isBackedUp
                                ? (auth.user?.email ?? auth.user?.displayName ?? '')
                                : LocaleKeys.signIn.tr,
                            style: AppTextStyles.caption(colors).copyWith(
                              color: colors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WebTopHeader extends StatelessWidget {
  const _WebTopHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: GetBuilder<ShellController>(
          id: 'shell',
          builder: (controller) {
            final area = controller.area;
            final isGoals = area == ShellArea.goals;

            return Row(
              children: [
                Icon(area.icon, color: area.accent(colors), size: AppIconSize.md),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  area.titleKey.tr,
                  style: AppTextStyles.h5(colors),
                ),
                const Spacer(),
                AppButton(
                  label: isGoals
                      ? LocaleKeys.addGoal.tr
                      : LocaleKeys.addExpense.tr,
                  onPressed: () {
                    if (isGoals) {
                      AppNavigator.toGoalEditor();
                    } else {
                      AppNavigator.toFinanceEntry(kind: FinanceKind.expense);
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
