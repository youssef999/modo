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
          icon: Icons.flag_outlined,
          title: LocaleKeys.goalsTitle.tr,
          subtitle: LocaleKeys.goalsSubtitle.tr,
          onTap: () => Get.find<ShellController>().selectArea(ShellArea.goals),
        ),
        const SizedBox(height: AppSpacing.sm),
        HomeAreaTile(
          icon: Icons.menu_book_outlined,
          title: LocaleKeys.journalTitle.tr,
          subtitle: LocaleKeys.journalSubtitle.tr,
          onTap: () =>
              Get.find<ShellController>().selectArea(ShellArea.journal),
        ),
        const SizedBox(height: AppSpacing.sm),
        HomeAreaTile(
          icon: Icons.account_balance_wallet_outlined,
          title: LocaleKeys.financeTitle.tr,
          subtitle: LocaleKeys.financeSubtitle.tr,
          onTap: () =>
              Get.find<ShellController>().selectArea(ShellArea.finance),
        ),
        const SizedBox(height: AppSpacing.sm),
        HomeAreaTile(
          icon: Icons.work_outline,
          title: LocaleKeys.workTitle.tr,
          subtitle: LocaleKeys.workSubtitle.tr,
          onTap: () => Get.find<ShellController>().selectArea(ShellArea.work),
        ),
      ],
    );
  }
}
