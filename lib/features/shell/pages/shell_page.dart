import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/features/finance/pages/finance_page.dart';
import 'package:life_daily_app/features/goals/pages/goals_page.dart';
import 'package:life_daily_app/features/home/widgets/name_intro_dialog.dart';
import 'package:life_daily_app/features/journal/pages/journal_page.dart';
import 'package:life_daily_app/features/shell/controllers/shell_controller.dart';
import 'package:life_daily_app/features/shell/widgets/app_shell_drawer.dart';
import 'package:life_daily_app/features/shell/widgets/app_shell_top_bar.dart';
import 'package:life_daily_app/features/work/pages/work_page.dart';
import 'package:life_daily_app/shared/widgets/ads/app_banner_ad.dart';
import 'package:life_daily_app/shared/widgets/layout/app_floating_nav_bar.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NameIntroDialog.showIfNeeded();
    });
  }

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
            Expanded(
              child: GetBuilder<ShellController>(
                id: 'shell',
                builder: (controller) {
                  return IndexedStack(
                    index: controller.area.index,
                    children: const [
                      GoalsPage(embed: true),
                      FinancePage(embed: true),
                      JournalPage(embed: true),
                      WorkPage(embed: true),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBannerAd(includeSafeArea: false),
          AppShellBottomChrome(),
        ],
      ),
    );
  }
}
