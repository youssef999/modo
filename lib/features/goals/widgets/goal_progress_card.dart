import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';

class GoalProgressCard extends StatelessWidget {
  const GoalProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GetBuilder<GoalsController>(
      id: 'goals',
      builder: (controller) {
        return AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              SizedBox(
                width: AppSpacing.xxl + AppSpacing.lg,
                height: AppSpacing.xxl + AppSpacing.lg,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: controller.progress,
                      strokeWidth: 7,
                      color: colors.primary,
                      backgroundColor: colors.border,
                    ),
                    Text(
                      '${controller.progressPercent}%',
                      style: AppTextStyles.h6(colors),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.goalProgressTitle.tr,
                      style: AppTextStyles.h6(colors),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      LocaleKeys.analysisGoals.trParams({
                        'done': '${controller.doneCount}',
                        'total': '${controller.totalCount}',
                      }),
                      style: AppTextStyles.body2(colors),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
