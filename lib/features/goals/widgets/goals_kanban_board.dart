import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_palette.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';
import 'package:life_daily_app/features/goals/widgets/app_priority_picker.dart';

class GoalsKanbanBoard extends StatelessWidget {
  const GoalsKanbanBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GoalsController>(
      id: 'goals',
      builder: (controller) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final isDesktop = screenWidth >= 900;
        
        final allColumns = <GoalStatus, Widget>{
          GoalStatus.notStarted: _buildColumn(
            context: context,
            controller: controller,
            status: GoalStatus.notStarted,
            title: LocaleKeys.statusNotStarted.tr,
            icon: Icons.radio_button_unchecked,
            accentColor: context.appPalette.textSecondary,
            showAdd: true,
          ),
          GoalStatus.inProgress: _buildColumn(
            context: context,
            controller: controller,
            status: GoalStatus.inProgress,
            title: LocaleKeys.statusInProgress.tr,
            icon: Icons.timelapse_rounded,
            accentColor: context.appPalette.info,
          ),
          GoalStatus.done: _buildColumn(
            context: context,
            controller: controller,
            status: GoalStatus.done,
            title: LocaleKeys.statusDone.tr,
            icon: Icons.check_circle_rounded,
            accentColor: context.appPalette.success,
          ),
          GoalStatus.archived: _buildColumn(
            context: context,
            controller: controller,
            status: GoalStatus.archived,
            title: LocaleKeys.statusArchived.tr,
            icon: Icons.inventory_2_outlined,
            accentColor: context.appPalette.textDisabled,
          ),
        };

        final columns = controller.statusFilter == null
            ? allColumns.values.toList()
            : [if (allColumns.containsKey(controller.statusFilter)) allColumns[controller.statusFilter]!];

        if (isDesktop) {
          if (columns.length == 1) {
            return Align(
              alignment: AlignmentDirectional.topStart,
              child: SizedBox(
                width: 320,
                child: columns.first,
              ),
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: columns.map((col) => Expanded(child: col)).toList(),
          );
        } else {
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: columns.length,
            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              return SizedBox(
                width: screenWidth * 0.85,
                child: columns[index],
              );
            },
          );
        }
      },
    );
  }

  Widget _buildColumn({
    required BuildContext context,
    required GoalsController controller,
    required GoalStatus status,
    required String title,
    required IconData icon,
    required Color accentColor,
    bool showAdd = false,
  }) {
    final colors = context.appPalette;
    final goals = controller.goalsByStatus[status] ?? [];
    
    return Container(
      margin: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(icon, color: accentColor, size: AppIconSize.md),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.h6(colors).copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    '${goals.length}',
                    style: AppTextStyles.caption(colors).copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Body (Drop target)
          Expanded(
            child: DragTarget<GoalModel>(
              onWillAcceptWithDetails: (details) => details.data.status != status,
              onAcceptWithDetails: (details) {
                controller.changeGoalStatus(details.data, status);
              },
              builder: (context, candidateData, rejectedData) {
                final isHovered = candidateData.isNotEmpty;
                
                return Container(
                  decoration: BoxDecoration(
                    color: isHovered ? accentColor.withValues(alpha: 0.05) : Colors.transparent,
                    border: isHovered 
                      ? Border.all(color: accentColor, width: 2)
                      : Border.all(color: Colors.transparent, width: 2),
                  ),
                  child: goals.isEmpty
                      ? _buildEmptyState(context, colors)
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          itemCount: goals.length,
                          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            return _buildDraggableCard(context, goals[index], controller);
                          },
                        ),
                );
              },
            ),
          ),
          // Footer
          if (showAdd)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => AppNavigator.toGoalEditor(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded, size: AppIconSize.md, color: colors.primary),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          LocaleKeys.addGoal.tr,
                          style: AppTextStyles.caption(colors).copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildEmptyState(BuildContext context, AppPalette colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            border: Border.all(
              color: colors.textDisabled.withValues(alpha: 0.3),
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.move_to_inbox_rounded, color: colors.textDisabled, size: AppIconSize.xl),
              const SizedBox(height: AppSpacing.md),
              Text(
                LocaleKeys.dragGoalHere.tr,
                style: AppTextStyles.body2(colors).copyWith(color: colors.textDisabled),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableCard(BuildContext context, GoalModel goal, GoalsController controller) {
    final platform = Theme.of(context).platform;
    final bool useNormalDraggable = kIsWeb || 
        platform == TargetPlatform.macOS || 
        platform == TargetPlatform.windows || 
        platform == TargetPlatform.linux;
    
    final child = _KanbanCard(goal: goal, controller: controller);
    
    final feedback = Transform.rotate(
      angle: 0.03,
      child: Opacity(
        opacity: 0.9,
        child: SizedBox(
          width: 250,
          child: Material(
            color: Colors.transparent,
            elevation: 8,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: child,
          ),
        ),
      ),
    );

    if (useNormalDraggable) {
      return Draggable<GoalModel>(
        data: goal,
        feedback: feedback,
        childWhenDragging: Opacity(
          opacity: 0.4,
          child: child,
        ),
        child: child,
      );
    } else {
      return LongPressDraggable<GoalModel>(
        data: goal,
        feedback: feedback,
        childWhenDragging: Opacity(
          opacity: 0.4,
          child: child,
        ),
        child: child,
      );
    }
  }
}

class _KanbanCard extends StatefulWidget {
  final GoalModel goal;
  final GoalsController controller;
  
  const _KanbanCard({required this.goal, required this.controller});

  @override
  State<_KanbanCard> createState() => _KanbanCardState();
}

class _KanbanCardState extends State<_KanbanCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final category = widget.controller.categoryById(widget.goal.category);
    final catColor = category?.color(colors) ?? colors.primary;
    final catIcon = category?.icon ?? Icons.flag_outlined;
    final catLabel = widget.controller.goalCategoryLabel(widget.goal);

    return GestureDetector(
      onTap: () => AppNavigator.toGoalDetail(widget.goal.id),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: _isHovered
                ? [BoxShadow(color: colors.shadow, blurRadius: 8, offset: const Offset(0, 4))]
                : [BoxShadow(color: colors.shadow, blurRadius: 2, offset: const Offset(0, 1))],
            border: Border.all(color: _isHovered ? catColor.withValues(alpha: 0.4) : colors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: catColor, width: 4),
                ),
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.goal.title,
                    style: AppTextStyles.h6(colors).copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(catIcon, size: AppIconSize.sm, color: colors.textSecondary),
                          const SizedBox(width: 4),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 100),
                            child: Text(
                              catLabel,
                              style: AppTextStyles.caption(colors),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      GoalPriorityBadge(
                        priority: widget.goal.priority,
                        onChanged: (newPriority) => widget.controller
                            .changeGoalPriority(widget.goal, newPriority),
                        compact: true,
                      ),
                      if (widget.goal.overallSuccessPercent > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            '${widget.goal.overallSuccessPercent}%',
                            style: AppTextStyles.caption(colors).copyWith(
                              color: colors.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (widget.goal.isHabit) ...[
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: LinearProgressIndicator(
                        value: widget.goal.progress,
                        backgroundColor: colors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(catColor),
                        minHeight: 4,
                      ),
                    ),
                  ],
                  if (widget.goal.tasks.isNotEmpty || widget.goal.members.length > 1) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        if (widget.goal.tasks.isNotEmpty) ...[
                          Icon(Icons.checklist_rounded, size: AppIconSize.sm, color: colors.textSecondary),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '${widget.goal.completedTasksCount}/${widget.goal.tasks.length}',
                            style: AppTextStyles.caption(colors),
                          ),
                        ],
                        if (widget.goal.members.length > 1) ...[
                          const Spacer(),
                          Icon(Icons.group_outlined, size: AppIconSize.sm, color: colors.primary),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '${widget.goal.members.length}',
                            style: AppTextStyles.caption(colors).copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
