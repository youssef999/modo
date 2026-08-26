import 'package:flutter/material.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/features/goals/widgets/goals_board.dart';
import 'package:life_daily_app/features/home/widgets/home_analysis_row.dart';
import 'package:life_daily_app/features/home/widgets/home_top_bar.dart';
import 'package:life_daily_app/features/home/widgets/home_welcome_banner.dart';
import 'package:life_daily_app/features/home/widgets/name_intro_dialog.dart';
import 'package:life_daily_app/shared/widgets/layout/app_scaffold.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.embed = false});

  final bool embed;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NameIntroDialog.showIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      embed: widget.embed,
      showHeader: false,
      body: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomeTopBar(),
            SizedBox(height: AppSpacing.md),
            HomeWelcomeBanner(),
            SizedBox(height: AppSpacing.lg),
            HomeAnalysisRow(),
            SizedBox(height: AppSpacing.md),
            GoalsBoard(shrinkWrap: true, showFilter: false),
          ],
        ),
      ),
    );
  }
}
