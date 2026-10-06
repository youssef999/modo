import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/features/home/widgets/home_area_tile.dart';
import 'package:life_daily_app/features/shell/controllers/shell_controller.dart';

class HomeAreas extends StatelessWidget {
  const HomeAreas({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HomeAreaTile(
          icon: Icons.calendar_today_rounded,
          title: LocaleKeys.todayTitle.tr,
          subtitle: LocaleKeys.myDay.tr,
          onTap: () => Get.find<ShellController>().selectArea(ShellArea.today),
        ),
        const SizedBox(height: AppSpacing.sm),
        HomeAreaTile(
          icon: Icons.task_alt_rounded,
          title: LocaleKeys.navTasks.tr,
          subtitle: LocaleKeys.allMyTasks.tr,
          onTap: () => Get.find<ShellController>().selectArea(ShellArea.goals),
        ),
        const SizedBox(height: AppSpacing.sm),
        HomeAreaTile(
          icon: Icons.account_balance_wallet_outlined,
          title: LocaleKeys.financeTitle.tr,
          subtitle: LocaleKeys.financeSubtitle.tr,
          onTap: () =>
              Get.find<ShellController>().selectArea(ShellArea.finance),
        ),
      ],
    );
  }
}
