import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/notifications/controllers/daily_reminder_controller.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';

class DailyReminderTile extends StatelessWidget {
  const DailyReminderTile({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GetBuilder<DailyReminderController>(
      id: 'reminder',
      builder: (reminder) {
        return AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                Icons.notifications_active_outlined,
                size: AppIconSize.lg,
                color: colors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.dailyReminder.tr,
                      style: AppTextStyles.body1(colors),
                    ),
                    Text(
                      LocaleKeys.dailyReminderTime.tr,
                      style: AppTextStyles.caption(colors),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: reminder.enabled,
                activeTrackColor: colors.primary,
                onChanged: reminder.setEnabled,
              ),
            ],
          ),
        );
      },
    );
  }
}
