import 'package:flutter/material.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/models/board_item.dart';
import 'package:life_daily_app/features/goals/widgets/board_goal_card.dart';
import 'package:life_daily_app/features/goals/widgets/board_task_card.dart';

class BoardItemCard extends StatelessWidget {
  const BoardItemCard({
    super.key,
    required this.item,
    required this.controller,
  });

  final BoardItem item;
  final GoalsController controller;

  @override
  Widget build(BuildContext context) {
    return switch (item) {
      GoalBoardItem(:final goal) => BoardGoalCard(
        goal: goal,
        controller: controller,
      ),
      TaskBoardItem(:final goal, :final task) => BoardTaskCard(
        goal: goal,
        task: task,
        controller: controller,
      ),
    };
  }
}
