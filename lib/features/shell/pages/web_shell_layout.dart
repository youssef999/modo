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
import 'package:life_daily_app/core/models/app_view_mode.dart';
import 'package:life_daily_app/features/auth/controllers/auth_controller.dart';
import 'package:life_daily_app/features/auth/widgets/auth_dialog.dart';
import 'package:life_daily_app/features/auth/widgets/profile_header.dart';
import 'package:life_daily_app/features/finance/pages/finance_page.dart';
import 'package:life_daily_app/features/daily/pages/daily_hub_page.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/pages/goals_page.dart';
import 'package:life_daily_app/features/goals/widgets/goal_invite_banner.dart';
import 'package:life_daily_app/features/notifications/widgets/daily_reminder_tile.dart';
import 'package:life_daily_app/features/shell/controllers/shell_controller.dart';
import 'package:life_daily_app/features/shell/widgets/quick_add_sheet.dart';
import 'package:life_daily_app/features/shell/widgets/shell_page_title.dart';
import 'package:life_daily_app/shared/widgets/branding/modo_brand.dart';
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
          // Collapsible Drawer
          GetBuilder<ShellController>(
            id: 'shell',
            builder: (controller) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeInOutCubic,
                width: controller.isDrawerOpen ? _WebDrawer.drawerWidth : 0.0,
                child: const ClipRect(
                  child: OverflowBox(
                    minWidth: _WebDrawer.drawerWidth,
                    maxWidth: _WebDrawer.drawerWidth,
                    alignment: AlignmentDirectional.topStart,
                    child: _WebDrawer(),
                  ),
                ),
              );
            },
          ),
          GetBuilder<ShellController>(
            id: 'shell',
            builder: (controller) => controller.isDrawerOpen
                ? VerticalDivider(width: 1, thickness: 1, color: colors.border)
                : const SizedBox.shrink(),
          ),
          // Main Content Area with Top Navigation
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _WebTopHeader(),
                const _WebSubNavBar(),
                const GoalInviteBanner(),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppLayout.wideMaxWidth,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.sm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(
                                AppSpacing.md,
                                AppSpacing.md,
                                AppSpacing.md,
                                AppSpacing.sm,
                              ),
                              child: ShellPageTitle(),
                            ),
                            Expanded(
                              child: GetBuilder<ShellController>(
                                id: 'shell',
                                builder: (controller) {
                                  return IndexedStack(
                                    index: controller.area.index,
                                    children: const [
                                      DailyHubPage(embed: true),
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
                    ),
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

/// Collapsible Drawer containing Workspace utilities, preferences, and account sync.
/// Note: Goals and Finance have been relocated to the Top Bar per user requirement.
class _WebDrawer extends StatelessWidget {
  const _WebDrawer();

  static const double drawerWidth = 270.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return SizedBox(
      width: drawerWidth,
      child: DecoratedBox(
        decoration: BoxDecoration(color: colors.card),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drawer Header with Close Button
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: ModoBrandLockup(),
                      ),
                    ),
                    GetBuilder<ShellController>(
                      id: 'shell',
                      builder: (ctrl) => IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: colors.textSecondary,
                          size: AppIconSize.md,
                        ),
                        tooltip: 'Close Drawer',
                        onPressed: ctrl.toggleDrawer,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Drawer Shortcuts and utilities
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  children: [
                    const ProfileHeader(),
                    const SizedBox(height: AppSpacing.md),
                    const Divider(height: 1),
                    const SizedBox(height: AppSpacing.md),

                    Text(
                      LocaleKeys.settings.tr,
                      style: AppTextStyles.caption(colors).copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Quick Shortcut to Month's Plan
                    _DrawerActionTile(
                      icon: Icons.calendar_month_rounded,
                      label: LocaleKeys.financeMonthPlan.tr,
                      onTap: () => AppNavigator.toMonthPlan(),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Quick Folders Shortcut
                    GetBuilder<ShellController>(
                      id: 'shell',
                      builder: (shell) => _DrawerActionTile(
                        icon: Icons.folder_open_rounded,
                        label: LocaleKeys.navFolders.tr,
                        onTap: () {
                          shell.selectArea(ShellArea.goals);
                          shell.selectSection(2);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Drawer Footer: Preferences & Cloud Sync
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _WebSyncCard(),
                    const SizedBox(height: AppSpacing.sm),
                    const DailyReminderTile(),
                    const SizedBox(height: AppSpacing.md),
                    const AppThemePicker(compact: true),
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

class _DrawerActionTile extends StatefulWidget {
  const _DrawerActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_DrawerActionTile> createState() => _DrawerActionTileState();
}

class _DrawerActionTileState extends State<_DrawerActionTile> {
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
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: _hovered ? colors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: AppIconSize.md,
                color: colors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.label,
                  style: AppTextStyles.body2(
                    colors,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: colors.textSecondary.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sleek Top Header with Drawer Toggle, Core Area Switcher, and Primary Action Button
class _WebTopHeader extends StatelessWidget {
  const _WebTopHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        border: Border(
          bottom: BorderSide(color: colors.border.withValues(alpha: 0.7)),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.02),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: GetBuilder<ShellController>(
          id: 'shell',
          builder: (controller) {
            return Row(
              children: [
                // Toggle Drawer Button
                IconButton(
                  icon: Icon(
                    controller.isDrawerOpen
                        ? Icons.menu_open_rounded
                        : Icons.menu_rounded,
                    color: colors.textPrimary,
                    size: AppIconSize.lg,
                  ),
                  tooltip: controller.isDrawerOpen ? 'Close Menu' : 'Open Menu',
                  onPressed: controller.toggleDrawer,
                ),
                const SizedBox(width: AppSpacing.xs),

                // Brand Pill — flexible so it can shrink on narrow screens
                const Flexible(
                  fit: FlexFit.loose,
                  child: ModoBrandLockup(logoSize: AppLogoSize.sm),
                ),

                const SizedBox(width: AppSpacing.sm),

                // Prominent Goals & Finance Capsule Switcher — centered, flexible
                Flexible(
                  flex: 2,
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: _AreaCapsuleSwitcher(
                        currentArea: controller.area,
                        onSelect: (area) => controller.selectArea(area),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                // Action Button
                AppButton(
                  label: LocaleKeys.quickAdd.tr,
                  variant: AppButtonVariant.primary,
                  onPressed: () =>
                      QuickAddSheet.show(context, type: controller.fabType),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Elegant Capsule Switcher across 4 areas in the Top Bar
class _AreaCapsuleSwitcher extends StatelessWidget {
  const _AreaCapsuleSwitcher({
    required this.currentArea,
    required this.onSelect,
  });

  final ShellArea currentArea;
  final ValueChanged<ShellArea> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CapsuleItem(
            icon: Icons.calendar_today_rounded,
            label: LocaleKeys.todayTitle.tr,
            selected: currentArea == ShellArea.today,
            activeColor: colors.primary,
            onTap: () => onSelect(ShellArea.today),
          ),
          const SizedBox(width: 4),
          _CapsuleItem(
            icon: Icons.task_alt_rounded,
            label: LocaleKeys.navTasks.tr,
            selected: currentArea == ShellArea.goals,
            activeColor: colors.info,
            onTap: () => onSelect(ShellArea.goals),
          ),
          const SizedBox(width: 4),
          _CapsuleItem(
            icon: Icons.account_balance_wallet_rounded,
            label: LocaleKeys.webNavFinance.tr,
            selected: currentArea == ShellArea.finance,
            activeColor: colors.success,
            onTap: () => onSelect(ShellArea.finance),
          ),
        ],
      ),
    );
  }
}

class _CapsuleItem extends StatefulWidget {
  const _CapsuleItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.activeColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  State<_CapsuleItem> createState() => _CapsuleItemState();
}

class _CapsuleItemState extends State<_CapsuleItem> {
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
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: widget.selected
                ? widget.activeColor.withValues(alpha: 0.15)
                : _hovered
                ? colors.card
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: widget.selected
                  ? widget.activeColor.withValues(alpha: 0.35)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: AppIconSize.md,
                color: widget.selected
                    ? widget.activeColor
                    : colors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Text(
                widget.label,
                style: AppTextStyles.body2(colors).copyWith(
                  fontWeight: widget.selected
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: widget.selected
                      ? widget.activeColor
                      : colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Secondary Top Bar with sub-navigation pills for Goals or Finance
class _WebSubNavBar extends StatelessWidget {
  const _WebSubNavBar();

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          bottom: BorderSide(color: colors.border.withValues(alpha: 0.6)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppLayout.wideMaxWidth),
            child: GetBuilder<ShellController>(
              id: 'shell',
              builder: (controller) {
                if (controller.area == ShellArea.today) {
                  return const SizedBox.shrink();
                }
                final isGoals = controller.area == ShellArea.goals;

                if (isGoals) {
                  return Row(
                    children: [
                      _SubTabPill(
                        icon: Icons.view_agenda_outlined,
                        label: LocaleKeys.navList.tr,
                        selected:
                            controller.sectionIndex == 0 &&
                            (!Get.isRegistered<GoalsController>() ||
                                Get.find<GoalsController>().viewMode !=
                                    AppViewMode.kanban),
                        onTap: () {
                          controller.selectSection(0);
                          if (Get.isRegistered<GoalsController>() &&
                              Get.find<GoalsController>().viewMode ==
                                  AppViewMode.kanban) {
                            Get.find<GoalsController>().setViewMode(
                              AppViewMode.list,
                            );
                          }
                        },
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _SubTabPill(
                        icon: Icons.view_kanban_rounded,
                        label: LocaleKeys.kanbanBoard.tr,
                        selected:
                            controller.sectionIndex == 0 &&
                            Get.isRegistered<GoalsController>() &&
                            Get.find<GoalsController>().viewMode ==
                                AppViewMode.kanban,
                        onTap: () {
                          controller.selectSection(0);
                          if (Get.isRegistered<GoalsController>()) {
                            Get.find<GoalsController>().setViewMode(
                              AppViewMode.kanban,
                            );
                          }
                        },
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _SubTabPill(
                        icon: Icons.insights_rounded,
                        label: LocaleKeys.navProgress.tr,
                        selected: controller.sectionIndex == 1,
                        onTap: () => controller.selectSection(1),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _SubTabPill(
                        icon: Icons.folder_outlined,
                        label: LocaleKeys.navFolders.tr,
                        selected: controller.sectionIndex == 2,
                        onTap: () => controller.selectSection(2),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _SubTabPill(
                        icon: Icons.check_circle_outline_rounded,
                        label: LocaleKeys.navDone.tr,
                        selected: controller.sectionIndex == 3,
                        onTap: () => controller.selectSection(3),
                      ),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      _SubTabPill(
                        icon: Icons.receipt_long_rounded,
                        label: LocaleKeys.navActivity.tr,
                        selected: controller.sectionIndex == 0,
                        onTap: () => controller.selectSection(0),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _SubTabPill(
                        icon: Icons.bar_chart_rounded,
                        label: LocaleKeys.financeCharts.tr,
                        selected: controller.sectionIndex == 1,
                        onTap: () => controller.selectSection(1),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _SubTabPill(
                        icon: Icons.description_outlined,
                        label: LocaleKeys.financeReports.tr,
                        selected: controller.sectionIndex == 2,
                        onTap: () => controller.selectSection(2),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _SubTabPill(
                        icon: Icons.calendar_month_outlined,
                        label: LocaleKeys.financeMonthPlan.tr,
                        selected: false,
                        onTap: () => AppNavigator.toMonthPlan(),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SubTabPill extends StatefulWidget {
  const _SubTabPill({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_SubTabPill> createState() => _SubTabPillState();
}

class _SubTabPillState extends State<_SubTabPill> {
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
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: widget.selected
                ? colors.primary.withValues(alpha: 0.12)
                : _hovered
                ? colors.card
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: widget.selected
                  ? colors.primary.withValues(alpha: 0.25)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: AppIconSize.sm,
                color: widget.selected ? colors.primary : colors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                widget.label,
                style: AppTextStyles.caption(colors).copyWith(
                  fontWeight: widget.selected
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: widget.selected
                      ? colors.primary
                      : colors.textSecondary,
                ),
              ),
            ],
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
                                ? (auth.user?.email ??
                                      auth.user?.displayName ??
                                      '')
                                : LocaleKeys.signIn.tr,
                            style: AppTextStyles.caption(
                              colors,
                            ).copyWith(color: colors.primary),
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
