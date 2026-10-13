import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/widgets/tasks_board.dart';
import 'package:life_daily_app/features/shell/controllers/shell_controller.dart';
import 'package:life_daily_app/features/shell/widgets/quick_add_sheet.dart';

/// The shell's "+": on the board it adds to the period being viewed.
void openShellQuickAdd(BuildContext context) {
  final shell = Get.find<ShellController>();
  if (shell.area == ShellArea.goals && Get.isRegistered<GoalsController>()) {
    openBoardQuickAdd(context, Get.find<GoalsController>());
    return;
  }
  QuickAddSheet.show(context, type: shell.fabType);
}
