import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/work/controllers/work_controller.dart';
import 'package:life_daily_app/features/work/models/work_item.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';
import 'package:life_daily_app/shared/widgets/feedback/app_confirm_dialog.dart';

class WorkItemTile extends StatelessWidget {
  const WorkItemTile({super.key, required this.item});

  final WorkItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GestureDetector(
                onTap: () => AppNavigator.toWorkEditor(item: item),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
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
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: _confirmDelete,
              icon: Icon(
                Icons.close_rounded,
                size: AppIconSize.sm,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
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
