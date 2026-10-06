import 'package:flutter/material.dart';
import 'package:life_daily_app/core/models/app_priority.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';
import 'package:life_daily_app/features/goals/models/goal_task.dart';
import 'package:life_daily_app/features/goals/widgets/app_priority_picker.dart';
import 'package:life_daily_app/features/goals/widgets/app_status_picker.dart';

class DailyTaskCard extends StatelessWidget {
  const DailyTaskCard({
    super.key,
    required this.goal,
    required this.goalTitle,
    required this.task,
    required this.onToggle,
    required this.onStatusChanged,
    required this.onPriorityChanged,
  });

  final GoalModel goal;
  final String goalTitle;
  final GoalTask task;
  final VoidCallback onToggle;
  final ValueChanged<GoalTaskStatus> onStatusChanged;
  final ValueChanged<AppPriority> onPriorityChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final isDone = task.isCompleted;

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDone
              ? colors.success.withValues(alpha: 0.3)
              : colors.border.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Checkbox
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(AppRadius.xs),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: isDone ? colors.success : Colors.transparent,
                    border: Border.all(
                      color: isDone
                          ? colors.success
                          : colors.textSecondary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: isDone
                      ? Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: colors.onPrimary,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Title
              Expanded(
                child: Text(
                  task.title,
                  style: AppTextStyles.body1(colors).copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? colors.textDisabled : colors.textPrimary,
                  ),
                ),
              ),

              // Priority Picker Badge
              TaskPriorityBadge(
                priority: task.priority,
                onChanged: onPriorityChanged,
                compact: true,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),

          // Bottom Tag Row: Time, Connected Goal, Status Badge, Assignee
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Time Tag (e.g. 🕒 09:30 AM)
                if (task.dueTime != null && task.dueTime!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      border: Border.all(
                        color: colors.border.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 11,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          task.dueTime!,
                          style: AppTextStyles.caption(colors).copyWith(
                            fontSize: 11,
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Connected Goal Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flag_rounded, size: 11, color: colors.primary),
                      const SizedBox(width: 3),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: Text(
                          goalTitle,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption(colors).copyWith(
                            fontSize: 11,
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Task Status Badge
                TaskStatusBadge(
                  status: task.status,
                  onChanged: onStatusChanged,
                  compact: true,
                ),

                // Assignee Badge
                if (task.assigneeName != null && task.assigneeName!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: colors.border.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 7,
                          backgroundColor: colors.primary,
                          child: Text(
                            task.assigneeName![0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 8,
                              color: colors.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.assigneeName!,
                          style: AppTextStyles.caption(
                            colors,
                          ).copyWith(fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                      ],
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
