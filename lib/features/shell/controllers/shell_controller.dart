import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/shell/models/quick_add_type.dart';

/// Index order matches the shell IndexedStack children.
enum ShellArea { today, goals, finance }

class ShellNavItem {
  const ShellNavItem({
    required this.icon,
    required this.labelKey,
    required this.area,
  });

  final IconData icon;
  final String labelKey;
  final ShellArea area;
}

class ShellController extends GetxController {
  ShellArea area = ShellArea.today;
  int sectionIndex = 0;
  bool isDrawerOpen = true;

  void toggleDrawer() {
    isDrawerOpen = !isDrawerOpen;
    update(['shell']);
  }

  void setDrawerOpen(bool open) {
    if (isDrawerOpen != open) {
      isDrawerOpen = open;
      update(['shell']);
    }
  }

  void selectArea(ShellArea value) {
    area = value;
    sectionIndex = 0;
    _syncFinanceTab();
    update(['shell']);
  }

  void selectSection(int index, {bool opensPlan = false}) {
    if (opensPlan) {
      AppNavigator.toMonthPlan();
      return;
    }
    sectionIndex = index;
    _syncFinanceTab();
    update(['shell']);
  }

  QuickAddType get fabType =>
      area == ShellArea.finance ? QuickAddType.money : QuickAddType.task;

  List<ShellNavItem> get leftItems {
    return const [
      ShellNavItem(
        icon: Icons.calendar_today_rounded,
        labelKey: LocaleKeys.todayTitle,
        area: ShellArea.today,
      ),
      ShellNavItem(
        icon: Icons.task_alt_rounded,
        labelKey: LocaleKeys.navTasks,
        area: ShellArea.goals,
      ),
    ];
  }

  List<ShellNavItem> get rightItems {
    return const [
      ShellNavItem(
        icon: Icons.account_balance_wallet_rounded,
        labelKey: LocaleKeys.financeTitle,
        area: ShellArea.finance,
      ),
    ];
  }

  void _syncFinanceTab() {
    if (area != ShellArea.finance) return;
    if (!Get.isRegistered<FinanceController>()) return;
    final finance = Get.find<FinanceController>();
    if (sectionIndex == 1) {
      finance.selectPageTab(FinancePageTab.charts);
    } else if (sectionIndex == 2) {
      finance.selectPageTab(FinancePageTab.reports);
    }
  }
}
