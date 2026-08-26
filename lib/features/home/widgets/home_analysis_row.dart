import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/finance/models/finance_month_snapshot.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/journal/controllers/journal_controller.dart';
import 'package:life_daily_app/features/shell/controllers/shell_controller.dart';
import 'package:life_daily_app/features/work/controllers/work_controller.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';

class HomeAnalysisRow extends StatelessWidget {
  const HomeAnalysisRow({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LocaleKeys.analysisTitle.tr, style: AppTextStyles.h6(colors)),
        const SizedBox(height: AppSpacing.md),
        GetBuilder<GoalsController>(
          id: 'goals',
          builder: (goals) {
            return GetBuilder<JournalController>(
              id: 'journal',
              builder: (journal) {
                return GetBuilder<WorkController>(
                  id: 'work',
                  builder: (work) {
                    return GetBuilder<FinanceController>(
                      id: 'finance',
                      builder: (finance) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _AnalysisTile(
                                    icon: Icons.flag_rounded,
                                    title: LocaleKeys.goalsTitle.tr,
                                    value: LocaleKeys.analysisGoals.trParams({
                                      'done': '${goals.doneCount}',
                                      'total': '${goals.totalCount}',
                                    }),
                                    emphasized: true,
                                    onTap: () => Get.find<ShellController>()
                                        .selectArea(ShellArea.goals),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: _AnalysisTile(
                                    icon: Icons.auto_stories_rounded,
                                    title: LocaleKeys.journalTitle.tr,
                                    value: LocaleKeys.journalCount.trParams({
                                      'count': '${journal.entries.length}',
                                    }),
                                    onTap: () => Get.find<ShellController>()
                                        .selectArea(ShellArea.journal),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Expanded(
                                  child: _AnalysisTile(
                                    icon: Icons.account_balance_wallet_rounded,
                                    title: LocaleKeys.financeTitle.tr,
                                    value: finance.hasActivity
                                        ? LocaleKeys.financeRemaining.trParams({
                                            'value':
                                                FinanceMonthSnapshot.format(
                                                  finance.snapshot.remaining,
                                                ),
                                          })
                                        : LocaleKeys.financeEmptyTitle.tr,
                                    onTap: () {
                                      Get.find<ShellController>().selectArea(
                                        ShellArea.finance,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: _AnalysisTile(
                                    icon: Icons.work_rounded,
                                    title: LocaleKeys.workTitle.tr,
                                    value: LocaleKeys.workOpenCount.trParams({
                                      'count': '${work.openItems.length}',
                                    }),
                                    onTap: () => Get.find<ShellController>()
                                        .selectArea(ShellArea.work),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _AnalysisTile extends StatelessWidget {
  const _AnalysisTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.emphasized = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final accent = emphasized ? colors.primary : colors.textSecondary;
    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSpacing.xl,
                height: AppSpacing.xl,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, size: AppIconSize.md, color: accent),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(title, style: AppTextStyles.caption(colors)),
              const SizedBox(height: AppSpacing.xs),
              Text(value, style: AppTextStyles.h6(colors), maxLines: 1),
            ],
          ),
        ),
      ),
    );
  }
}
