import 'package:get/get.dart';
import 'package:life_daily_app/core/bindings/initial_binding.dart';
import 'package:life_daily_app/features/auth/bindings/auth_binding.dart';
import 'package:life_daily_app/features/finance/bindings/finance_binding.dart';
import 'package:life_daily_app/features/finance/models/finance_category_role.dart';
import 'package:life_daily_app/features/finance/models/finance_entry.dart';
import 'package:life_daily_app/features/finance/pages/finance_all_entries_page.dart';
import 'package:life_daily_app/features/finance/pages/finance_category_page.dart';
import 'package:life_daily_app/features/finance/pages/finance_entry_page.dart';
import 'package:life_daily_app/features/finance/pages/finance_month_plan_page.dart';
import 'package:life_daily_app/features/finance/pages/finance_page.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';
import 'package:life_daily_app/features/goals/pages/goal_category_page.dart';
import 'package:life_daily_app/features/goals/pages/goal_editor_page.dart';
import 'package:life_daily_app/features/goals/pages/goals_all_page.dart';
import 'package:life_daily_app/features/goals/pages/goals_page.dart';
import 'package:life_daily_app/features/goals/bindings/goals_binding.dart';
import 'package:life_daily_app/features/home/bindings/home_binding.dart';
import 'package:life_daily_app/features/journal/bindings/journal_binding.dart';
import 'package:life_daily_app/features/journal/models/journal_entry.dart';
import 'package:life_daily_app/features/journal/pages/journal_all_log_page.dart';
import 'package:life_daily_app/features/journal/pages/journal_editor_page.dart';
import 'package:life_daily_app/features/journal/pages/journal_page.dart';
import 'package:life_daily_app/features/shell/bindings/shell_binding.dart';
import 'package:life_daily_app/features/shell/pages/shell_page.dart';
import 'package:life_daily_app/features/work/bindings/work_binding.dart';
import 'package:life_daily_app/features/work/models/work_item.dart';
import 'package:life_daily_app/features/work/pages/work_editor_page.dart';
import 'package:life_daily_app/features/work/pages/work_page.dart';

class AppNavigator {
  AppNavigator._();

  static void offAllHome() {
    Get.offAll(() => const ShellPage(), binding: ShellBinding());
  }

  static Future<T?> toGoals<T>() {
    return Get.to<T>(() => const GoalsPage()) ?? Future<T?>.value();
  }

  static Future<T?> toJournal<T>() {
    return Get.to<T>(() => const JournalPage(), binding: JournalBinding()) ??
        Future<T?>.value();
  }

  static Future<T?> toFinance<T>() {
    return Get.to<T>(() => const FinancePage(), binding: FinanceBinding()) ??
        Future<T?>.value();
  }

  static Future<T?> toGoalEditor<T>({GoalModel? goal}) {
    return Get.to<T>(
          () => GoalEditorPage(goal: goal),
          binding: GoalsBinding(),
        ) ??
        Future<T?>.value();
  }

  static Future<T?> toFinanceEntry<T>({required FinanceKind kind}) {
    return Get.to<T>(
          () => FinanceEntryPage(kind: kind),
          binding: FinanceBinding(),
        ) ??
        Future<T?>.value();
  }

  static Future<T?> toFinanceAllEntries<T>() {
    return Get.to<T>(
          () => const FinanceAllEntriesPage(),
          binding: FinanceBinding(),
        ) ??
        Future<T?>.value();
  }

  static Future<T?> toGoalsAll<T>({bool doneOnly = false}) {
    return Get.to<T>(
          () => GoalsAllPage(doneOnly: doneOnly),
          binding: GoalsBinding(),
        ) ??
        Future<T?>.value();
  }

  static Future<T?> toJournalAllLog<T>() {
    return Get.to<T>(
          () => const JournalAllLogPage(),
          binding: JournalBinding(),
        ) ??
        Future<T?>.value();
  }

  static Future<String?> toFinanceCategory({
    FinanceCategoryRole role = FinanceCategoryRole.spend,
  }) {
    return Get.to<String>(
          () => FinanceCategoryPage(initialRole: role),
          binding: FinanceBinding(),
        ) ??
        Future<String?>.value();
  }

  static Future<String?> toGoalCategory() {
    return Get.to<String>(
          () => const GoalCategoryPage(),
          binding: GoalsBinding(),
        ) ??
        Future<String?>.value();
  }

  static Future<T?> toMonthPlan<T>() {
    return Get.to<T>(
          () => const FinanceMonthPlanPage(),
          binding: FinanceBinding(),
        ) ??
        Future<T?>.value();
  }

  static Future<T?> toJournalEditor<T>({
    JournalEntry? entry,
    String? draftTitle,
    String? draftDetails,
    String? folderId,
  }) {
    return Get.to<T>(
          () => JournalEditorPage(
            entry: entry,
            draftTitle: draftTitle,
            draftDetails: draftDetails,
            folderId: folderId,
          ),
          binding: JournalBinding(),
        ) ??
        Future<T?>.value();
  }

  static Future<T?> toWorkEditor<T>({
    WorkItem? item,
    String? draftTitle,
    String? draftDetails,
    String? folderId,
  }) {
    return Get.to<T>(
          () => WorkEditorPage(
            item: item,
            draftTitle: draftTitle,
            draftDetails: draftDetails,
            folderId: folderId,
          ),
          binding: WorkBinding(),
        ) ??
        Future<T?>.value();
  }

  static Future<T?> toWork<T>() {
    return Get.to<T>(() => const WorkPage(), binding: WorkBinding()) ??
        Future<T?>.value();
  }

  static void back<T>([T? result]) {
    Get.back<T>(result: result);
  }
}

class AppStartBinding extends Bindings {
  @override
  void dependencies() {
    InitialBinding().dependencies();
    AuthBinding().dependencies();
    HomeBinding().dependencies();
    GoalsBinding().dependencies();
    FinanceBinding().dependencies();
    JournalBinding().dependencies();
    WorkBinding().dependencies();
    ShellBinding().dependencies();
  }
}
