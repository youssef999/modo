import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_palette.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';
import 'package:life_daily_app/features/goals/models/goal_task.dart';

class StatusVisualConfig {
  const StatusVisualConfig({
    required this.color,
    required this.bgColor,
    required this.icon,
    required this.label,
  });

  final Color color;
  final Color bgColor;
  final IconData icon;
  final String label;

  static StatusVisualConfig forGoalStatus(
    GoalStatus status,
    AppPalette colors,
  ) {
    return switch (status) {
      GoalStatus.notStarted => forTaskStatus(GoalTaskStatus.todo, colors),
      GoalStatus.inProgress => forTaskStatus(GoalTaskStatus.inProgress, colors),
      GoalStatus.pending => forTaskStatus(GoalTaskStatus.pending, colors),
      GoalStatus.done => forTaskStatus(GoalTaskStatus.done, colors),
      GoalStatus.archived => StatusVisualConfig(
        color: colors.textDisabled,
        bgColor: colors.textDisabled.withValues(alpha: 0.12),
        icon: Icons.inventory_2_outlined,
        label: LocaleKeys.statusArchived.tr,
      ),
    };
  }

  static StatusVisualConfig forTaskStatus(
    GoalTaskStatus status,
    AppPalette colors,
  ) {
    return switch (status) {
      GoalTaskStatus.todo => StatusVisualConfig(
        color: colors.textSecondary,
        bgColor: colors.textSecondary.withValues(alpha: 0.12),
        icon: Icons.radio_button_unchecked,
        label: LocaleKeys.taskStatusTodo.tr,
      ),
      GoalTaskStatus.pending => StatusVisualConfig(
        color: colors.warning,
        bgColor: colors.warning.withValues(alpha: 0.14),
        icon: Icons.hourglass_top_rounded,
        label: LocaleKeys.taskStatusPending.tr,
      ),
      GoalTaskStatus.inProgress => StatusVisualConfig(
        color: colors.info,
        bgColor: colors.info.withValues(alpha: 0.14),
        icon: Icons.timelapse_rounded,
        label: LocaleKeys.taskStatusInProgress.tr,
      ),
      GoalTaskStatus.done => StatusVisualConfig(
        color: colors.success,
        bgColor: colors.success.withValues(alpha: 0.14),
        icon: Icons.check_circle_rounded,
        label: LocaleKeys.taskStatusDone.tr,
      ),
    };
  }
}

class GoalStatusBadge extends StatelessWidget {
  const GoalStatusBadge({
    super.key,
    required this.status,
    this.onChanged,
    this.compact = false,
  });

  final GoalStatus status;
  final ValueChanged<GoalStatus>? onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final config = StatusVisualConfig.forGoalStatus(status, colors);
    final isClickable = onChanged != null;

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.xs + 2 : AppSpacing.sm + 2,
        vertical: compact ? 2 : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: config.color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 6 : 8,
            height: compact ? 6 : 8,
            decoration: BoxDecoration(
              color: config.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: config.color.withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: 0.5,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            config.label,
            style: AppTextStyles.caption(colors).copyWith(
              color: config.color,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 11 : 12,
            ),
          ),
          if (isClickable) ...[
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: compact ? 14 : AppIconSize.sm,
              color: config.color.withValues(alpha: 0.8),
            ),
          ],
        ],
      ),
    );

    if (!isClickable) return content;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          final chosen = await AppStatusPickerSheet.showGoalStatusPicker(
            context,
            currentStatus: status,
          );
          if (chosen != null && chosen != status) {
            onChanged!(chosen);
          }
        },
        child: content,
      ),
    );
  }
}

class TaskStatusBadge extends StatelessWidget {
  const TaskStatusBadge({
    super.key,
    required this.status,
    this.onChanged,
    this.compact = false,
  });

  final GoalTaskStatus status;
  final ValueChanged<GoalTaskStatus>? onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final config = StatusVisualConfig.forTaskStatus(status, colors);
    final isClickable = onChanged != null;

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.xs + 2 : AppSpacing.sm + 2,
        vertical: compact ? 2 : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: config.color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 6 : 8,
            height: compact ? 6 : 8,
            decoration: BoxDecoration(
              color: config.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: config.color.withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: 0.5,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            config.label,
            style: AppTextStyles.caption(colors).copyWith(
              color: config.color,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 11 : 12,
            ),
          ),
          if (isClickable) ...[
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: compact ? 14 : AppIconSize.sm,
              color: config.color.withValues(alpha: 0.8),
            ),
          ],
        ],
      ),
    );

    if (!isClickable) return content;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          final chosen = await AppStatusPickerSheet.showTaskStatusPicker(
            context,
            currentStatus: status,
          );
          if (chosen != null && chosen != status) {
            onChanged!(chosen);
          }
        },
        child: content,
      ),
    );
  }
}

class AppStatusPickerSheet {
  static Future<GoalStatus?> showGoalStatusPicker(
    BuildContext context, {
    required GoalStatus currentStatus,
  }) {
    return _showModal<GoalStatus>(
      context,
      title: LocaleKeys.selectStatus.tr,
      builder: (ctx) => _GoalStatusList(currentStatus: currentStatus),
    );
  }

  static Future<GoalTaskStatus?> showTaskStatusPicker(
    BuildContext context, {
    required GoalTaskStatus currentStatus,
  }) {
    return _showModal<GoalTaskStatus>(
      context,
      title: LocaleKeys.selectStatus.tr,
      builder: (ctx) => _TaskStatusList(currentStatus: currentStatus),
    );
  }

  static Future<T?> _showModal<T>(
    BuildContext context, {
    required String title,
    required WidgetBuilder builder,
  }) {
    final colors = context.appPalette;
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    if (isWide) {
      return showDialog<T>(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Container(
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: colors.border),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(title, style: AppTextStyles.h6(colors)),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: Icon(
                          Icons.close_rounded,
                          size: AppIconSize.md,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  builder(ctx),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
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
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              Text(title, style: AppTextStyles.h6(colors)),
              const SizedBox(height: AppSpacing.md),
              builder(ctx),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalStatusList extends StatelessWidget {
  const _GoalStatusList({required this.currentStatus});

  final GoalStatus currentStatus;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(label: LocaleKeys.statusSectionTodo.tr),
        _StatusOptionTile<GoalStatus>(
          value: GoalStatus.notStarted,
          selected: currentStatus == GoalStatus.notStarted,
          config: StatusVisualConfig.forGoalStatus(
            GoalStatus.notStarted,
            colors,
          ),
          onTap: () => Navigator.of(context).pop(GoalStatus.notStarted),
        ),
        _StatusOptionTile<GoalStatus>(
          value: GoalStatus.pending,
          selected: currentStatus == GoalStatus.pending,
          config: StatusVisualConfig.forGoalStatus(GoalStatus.pending, colors),
          onTap: () => Navigator.of(context).pop(GoalStatus.pending),
        ),
        const SizedBox(height: AppSpacing.xs),
        _SectionHeader(label: LocaleKeys.statusSectionInProgress.tr),
        _StatusOptionTile<GoalStatus>(
          value: GoalStatus.inProgress,
          selected: currentStatus == GoalStatus.inProgress,
          config: StatusVisualConfig.forGoalStatus(
            GoalStatus.inProgress,
            colors,
          ),
          onTap: () => Navigator.of(context).pop(GoalStatus.inProgress),
        ),
        const SizedBox(height: AppSpacing.xs),
        _SectionHeader(label: LocaleKeys.statusSectionComplete.tr),
        _StatusOptionTile<GoalStatus>(
          value: GoalStatus.done,
          selected: currentStatus == GoalStatus.done,
          config: StatusVisualConfig.forGoalStatus(GoalStatus.done, colors),
          onTap: () => Navigator.of(context).pop(GoalStatus.done),
        ),
        _StatusOptionTile<GoalStatus>(
          value: GoalStatus.archived,
          selected: currentStatus == GoalStatus.archived,
          config: StatusVisualConfig.forGoalStatus(GoalStatus.archived, colors),
          onTap: () => Navigator.of(context).pop(GoalStatus.archived),
        ),
      ],
    );
  }
}

class _TaskStatusList extends StatelessWidget {
  const _TaskStatusList({required this.currentStatus});

  final GoalTaskStatus currentStatus;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(label: LocaleKeys.statusSectionTodo.tr),
        _StatusOptionTile<GoalTaskStatus>(
          value: GoalTaskStatus.todo,
          selected: currentStatus == GoalTaskStatus.todo,
          config: StatusVisualConfig.forTaskStatus(GoalTaskStatus.todo, colors),
          onTap: () => Navigator.of(context).pop(GoalTaskStatus.todo),
        ),
        _StatusOptionTile<GoalTaskStatus>(
          value: GoalTaskStatus.pending,
          selected: currentStatus == GoalTaskStatus.pending,
          config: StatusVisualConfig.forTaskStatus(
            GoalTaskStatus.pending,
            colors,
          ),
          onTap: () => Navigator.of(context).pop(GoalTaskStatus.pending),
        ),
        const SizedBox(height: AppSpacing.xs),
        _SectionHeader(label: LocaleKeys.statusSectionInProgress.tr),
        _StatusOptionTile<GoalTaskStatus>(
          value: GoalTaskStatus.inProgress,
          selected: currentStatus == GoalTaskStatus.inProgress,
          config: StatusVisualConfig.forTaskStatus(
            GoalTaskStatus.inProgress,
            colors,
          ),
          onTap: () => Navigator.of(context).pop(GoalTaskStatus.inProgress),
        ),
        const SizedBox(height: AppSpacing.xs),
        _SectionHeader(label: LocaleKeys.statusSectionComplete.tr),
        _StatusOptionTile<GoalTaskStatus>(
          value: GoalTaskStatus.done,
          selected: currentStatus == GoalTaskStatus.done,
          config: StatusVisualConfig.forTaskStatus(GoalTaskStatus.done, colors),
          onTap: () => Navigator.of(context).pop(GoalTaskStatus.done),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        right: AppSpacing.xs,
        top: AppSpacing.sm,
        bottom: AppSpacing.xs,
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(colors).copyWith(
          color: colors.textDisabled,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _StatusOptionTile<T> extends StatefulWidget {
  const _StatusOptionTile({
    required this.value,
    required this.selected,
    required this.config,
    required this.onTap,
  });

  final T value;
  final bool selected;
  final StatusVisualConfig config;
  final VoidCallback onTap;

  @override
  State<_StatusOptionTile<T>> createState() => _StatusOptionTileState<T>();
}

class _StatusOptionTileState<T> extends State<_StatusOptionTile<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final isSelected = widget.selected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? widget.config.bgColor
                : (_hovered ? colors.surface : Colors.transparent),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected
                  ? widget.config.color.withValues(alpha: 0.35)
                  : (_hovered ? colors.border : Colors.transparent),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: widget.config.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.config.color.withValues(alpha: 0.45),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                widget.config.icon,
                size: AppIconSize.sm,
                color: widget.config.color,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  widget.config.label,
                  style: AppTextStyles.body2(colors).copyWith(
                    color: isSelected
                        ? widget.config.color
                        : colors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_rounded,
                  size: AppIconSize.md,
                  color: widget.config.color,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
