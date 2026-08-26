import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/work/controllers/work_controller.dart';
import 'package:life_daily_app/features/work/models/work_item.dart';
import 'package:life_daily_app/core/models/app_view_mode.dart';
import 'package:life_daily_app/features/work/widgets/work_item_grid_card.dart';
import 'package:life_daily_app/features/work/widgets/work_item_tile.dart';
import 'package:life_daily_app/shared/widgets/layout/app_view_mode_toggle.dart';

class WorkItemsView extends StatelessWidget {
  const WorkItemsView({
    super.key,
    required this.items,
    required this.title,
    this.showToggle = true,
  });

  final List<WorkItem> items;
  final String title;
  final bool showToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GetBuilder<WorkController>(
      id: 'work',
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: AppTextStyles.h6(colors)),
                ),
                if (showToggle)
                  AppViewModeToggle(
                    isGrid: controller.isGridView,
                    onList: () => controller.setViewMode(AppViewMode.list),
                    onGrid: () => controller.setViewMode(AppViewMode.grid),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: controller.isGridView
                  ? _GridItems(items: items)
                  : _ListItems(items: items),
            ),
          ],
        );
      },
    );
  }
}

class _ListItems extends StatelessWidget {
  const _ListItems({required this.items});

  final List<WorkItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => WorkItemTile(item: items[index]),
    );
  }
}

class _GridItems extends StatelessWidget {
  const _GridItems({required this.items});

  final List<WorkItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.92,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => WorkItemGridCard(item: items[index]),
    );
  }
}
