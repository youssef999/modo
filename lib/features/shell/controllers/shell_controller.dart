import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/finance/models/finance_entry.dart';
import 'package:life_daily_app/features/journal/controllers/journal_controller.dart';
import 'package:life_daily_app/features/journal/models/journal_folder.dart';
import 'package:life_daily_app/features/work/controllers/work_controller.dart';
import 'package:life_daily_app/features/work/models/work_folder.dart';

enum ShellArea { goals, finance, journal, work }

class ShellNavItem {
  const ShellNavItem({
    required this.icon,
    required this.labelKey,
    required this.sectionIndex,
    this.opensPlan = false,
    this.opensDatePicker = false,
    this.focusSearch = false,
  });

  final IconData icon;
  final String labelKey;
  final int sectionIndex;
  final bool opensPlan;
  final bool opensDatePicker;
  final bool focusSearch;
}

class ShellController extends GetxController {
  ShellArea area = ShellArea.goals;
  int sectionIndex = 0;

  void selectArea(ShellArea value) {
    area = value;
    sectionIndex = 0;
    _syncFinanceTab();
    update(['shell']);
  }

  void selectSection(
    int index, {
    bool opensPlan = false,
    bool opensDatePicker = false,
    bool focusSearch = false,
  }) {
    if (opensPlan) {
      AppNavigator.toMonthPlan();
      return;
    }
    sectionIndex = index;
    _syncFinanceTab();
    update(['shell']);
    if (opensDatePicker && Get.isRegistered<JournalController>()) {
      Get.find<JournalController>().requestDatePicker();
    }
    if (focusSearch && Get.isRegistered<JournalController>()) {
      Get.find<JournalController>().requestSearchFocus();
    }
  }

  void onFab() {
    switch (area) {
      case ShellArea.goals:
        AppNavigator.toGoalEditor();
      case ShellArea.finance:
        AppNavigator.toFinanceEntry(kind: FinanceKind.expense);
      case ShellArea.journal:
        AppNavigator.toJournalEditor(
          folderId: Get.isRegistered<JournalController>()
              ? Get.find<JournalController>().selectedFolderId ??
                    JournalFolder.generalId
              : JournalFolder.generalId,
        );
      case ShellArea.work:
        AppNavigator.toWorkEditor(
          folderId: Get.isRegistered<WorkController>()
              ? Get.find<WorkController>().selectedFolderId ??
                    WorkFolder.generalId
              : WorkFolder.generalId,
        );
    }
  }

  List<ShellNavItem> get leftItems {
    return switch (area) {
      ShellArea.goals => const [
        ShellNavItem(
          icon: Icons.flag_outlined,
          labelKey: LocaleKeys.navList,
          sectionIndex: 0,
        ),
        ShellNavItem(
          icon: Icons.donut_large_outlined,
          labelKey: LocaleKeys.navProgress,
          sectionIndex: 1,
        ),
      ],
      ShellArea.finance => const [
        ShellNavItem(
          icon: Icons.receipt_long_outlined,
          labelKey: LocaleKeys.navActivity,
          sectionIndex: 0,
        ),
        ShellNavItem(
          icon: Icons.pie_chart_outline_rounded,
          labelKey: LocaleKeys.financeCharts,
          sectionIndex: 1,
        ),
      ],
      ShellArea.journal => const [
        ShellNavItem(
          icon: Icons.home_outlined,
          labelKey: LocaleKeys.navHome,
          sectionIndex: 0,
        ),
        ShellNavItem(
          icon: Icons.view_agenda_outlined,
          labelKey: LocaleKeys.journalLog,
          sectionIndex: 1,
        ),
      ],
      ShellArea.work => const [
        ShellNavItem(
          icon: Icons.home_outlined,
          labelKey: LocaleKeys.navHome,
          sectionIndex: 0,
        ),
        ShellNavItem(
          icon: Icons.work_outline,
          labelKey: LocaleKeys.navTasks,
          sectionIndex: 1,
        ),
      ],
    };
  }

  List<ShellNavItem> get rightItems {
    return switch (area) {
      ShellArea.goals => const [
        ShellNavItem(
          icon: Icons.folder_outlined,
          labelKey: LocaleKeys.navFolders,
          sectionIndex: 2,
        ),
        ShellNavItem(
          icon: Icons.task_alt_outlined,
          labelKey: LocaleKeys.navDone,
          sectionIndex: 3,
        ),
      ],
      ShellArea.finance => const [
        ShellNavItem(
          icon: Icons.insights_outlined,
          labelKey: LocaleKeys.financeReports,
          sectionIndex: 2,
        ),
        ShellNavItem(
          icon: Icons.account_balance_wallet_outlined,
          labelKey: LocaleKeys.financeMonthPlan,
          sectionIndex: 2,
          opensPlan: true,
        ),
      ],
      ShellArea.journal => const [
        ShellNavItem(
          icon: Icons.folder_outlined,
          labelKey: LocaleKeys.navFolders,
          sectionIndex: 2,
        ),
        ShellNavItem(
          icon: Icons.search_rounded,
          labelKey: LocaleKeys.navSearch,
          sectionIndex: 3,
          focusSearch: true,
        ),
      ],
      ShellArea.work => const [
        ShellNavItem(
          icon: Icons.folder_outlined,
          labelKey: LocaleKeys.navFolders,
          sectionIndex: 2,
        ),
        ShellNavItem(
          icon: Icons.task_alt_outlined,
          labelKey: LocaleKeys.navDone,
          sectionIndex: 3,
        ),
      ],
    };
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
