import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/features/daily/pages/daily_hub_page.dart';
import 'package:life_daily_app/features/finance/pages/finance_page.dart';
import 'package:life_daily_app/features/goals/pages/goals_page.dart';
import 'package:life_daily_app/features/goals/widgets/goal_invite_banner.dart';
import 'package:life_daily_app/features/shell/controllers/shell_controller.dart';
import 'package:life_daily_app/features/shell/widgets/app_shell_drawer.dart';
import 'package:life_daily_app/features/shell/widgets/app_shell_top_bar.dart';
import 'package:life_daily_app/features/shell/widgets/quick_add_sheet.dart';
import 'package:life_daily_app/shared/widgets/ads/app_banner_ad.dart';
import 'package:life_daily_app/shared/widgets/layout/app_floating_nav_bar.dart';

class MobileShellLayout extends StatelessWidget {
  const MobileShellLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return Scaffold(
      backgroundColor: colors.background,
      extendBody: true,
      drawer: const AppShellDrawer(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppShellTopBar(),
            const GoalInviteBanner(),
            Expanded(
              child: GetBuilder<ShellController>(
                id: 'shell',
                builder: (controller) {
                  return IndexedStack(
                    index: controller.area.index,
                    children: const [
                      DailyHubPage(embed: true),
                      GoalsPage(embed: true),
                      FinancePage(embed: true),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppBannerAd(includeSafeArea: false),
          AppShellBottomChrome(
            onFabTap: () => QuickAddSheet.show(
              context,
              type: Get.find<ShellController>().fabType,
            ),
          ),
        ],
      ),
    );
  }
}
