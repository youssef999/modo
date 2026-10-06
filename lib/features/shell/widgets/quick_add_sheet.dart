import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/breakpoints.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/finance/models/finance_entry.dart';
import 'package:life_daily_app/features/finance/widgets/add_finance_entry_dialog.dart';
import 'package:life_daily_app/features/goals/models/goal_task.dart';
import 'package:life_daily_app/features/shell/models/quick_add_type.dart';
import 'package:life_daily_app/features/shell/widgets/quick_add/quick_add_task_form.dart';
import 'package:life_daily_app/features/shell/widgets/quick_add/quick_add_type_switch.dart';

/// Single entry point for adding a task, a money entry, or a goal.
class QuickAddSheet {
  QuickAddSheet._();

  static const double _dialogMaxWidth = 440;

  static bool _isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;

  static Future<void> show(
    BuildContext context, {
    QuickAddType type = QuickAddType.task,
    DateTime? date,
    GoalTaskStatus? status,
    String? goalId,
    String? categoryId,
  }) async {
    if (type != QuickAddType.task) {
      await _openOther(context, type);
      return;
    }
    final colors = context.appPalette;
    final isDesktop = _isDesktop(context);

    Widget panel(BuildContext sheetContext) => _QuickAddPanel(
      date: date,
      status: status,
      goalId: goalId,
      categoryId: categoryId,
      onClose: () => Navigator.of(sheetContext).pop(),
      onSwitch: (next) {
        Navigator.of(sheetContext).pop();
        if (context.mounted) _openOther(context, next);
      },
    );

    if (isDesktop) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _dialogMaxWidth),
            child: panel(ctx),
          ),
        ),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: colors.card,
      barrierColor: colors.textPrimary.withValues(alpha: 0.25),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: panel(ctx),
      ),
    );
  }

  static Future<void> _openOther(
    BuildContext context,
    QuickAddType type,
  ) async {
    switch (type) {
      case QuickAddType.task:
        return;
      case QuickAddType.money:
        if (_isDesktop(context)) {
          await AddFinanceEntryDialog.show(context);
        } else {
          await AppNavigator.toFinanceEntry(kind: FinanceKind.expense);
        }
      case QuickAddType.goal:
        await AppNavigator.toGoalEditor();
    }
  }
}

class _QuickAddPanel extends StatelessWidget {
  const _QuickAddPanel({
    required this.onClose,
    required this.onSwitch,
    this.date,
    this.status,
    this.goalId,
    this.categoryId,
  });

  final VoidCallback onClose;
  final ValueChanged<QuickAddType> onSwitch;
  final DateTime? date;
  final GoalTaskStatus? status;
  final String? goalId;
  final String? categoryId;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(LocaleKeys.quickAdd.tr, style: AppTextStyles.h6(colors)),
              const Spacer(),
              IconButton(
                onPressed: onClose,
                tooltip: LocaleKeys.cancel.tr,
                icon: Icon(
                  Icons.close_rounded,
                  size: AppIconSize.md,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          QuickAddTypeSwitch(
            value: QuickAddType.task,
            onChanged: (type) {
              if (type != QuickAddType.task) onSwitch(type);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          QuickAddTaskForm(
            date: date,
            status: status,
            goalId: goalId,
            categoryId: categoryId,
            onDone: onClose,
          ),
        ],
      ),
    );
  }
}
