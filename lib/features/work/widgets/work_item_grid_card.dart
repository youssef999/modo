import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/work/controllers/work_controller.dart';
import 'package:life_daily_app/features/work/models/work_item.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';
import 'package:life_daily_app/shared/widgets/feedback/app_confirm_dialog.dart';

class WorkItemGridCard extends StatelessWidget {
  const WorkItemGridCard({super.key, required this.item});

  final WorkItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.find<WorkController>().toggle(item),
                child: Icon(
                  item.isDone
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: item.isDone ? colors.success : colors.primary,
                  size: AppIconSize.lg,
                ),
              ),
              const Spacer(),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _confirmDelete,
                icon: Icon(
                  Icons.close_rounded,
                  size: AppIconSize.sm,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: GestureDetector(
              onTap: () => AppNavigator.toWorkEditor(item: item),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h6(colors).copyWith(
                      decoration: item.isDone
                          ? TextDecoration.lineThrough
                          : null,
                      color: item.isDone
                          ? colors.textSecondary
                          : colors.textPrimary,
                    ),
                  ),
                  if (item.details.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.details,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body2(colors),
                    ),
                  ],
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      item.isDone
                          ? LocaleKeys.navDone.tr
                          : LocaleKeys.navTasks.tr,
                      style: AppTextStyles.caption(colors).copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final ok = await AppConfirmDialog.show(
      title: LocaleKeys.confirmDeleteTitle.tr,
      message: LocaleKeys.confirmDeleteWork.tr,
    );
    if (!ok) return;
    await Get.find<WorkController>().delete(item);
  }
}
