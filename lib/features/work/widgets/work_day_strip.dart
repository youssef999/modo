import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/utils/week_progress.dart';
import 'package:life_daily_app/features/work/controllers/work_controller.dart';
import 'package:life_daily_app/shared/widgets/layout/app_day_strip.dart';

class WorkDayStrip extends StatelessWidget {
  const WorkDayStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WorkController>(
      id: 'work',
      builder: (controller) {
        return AppDayStrip(
          days: controller.nearbyDays(),
          selectedKey: controller.selectedDayKey,
          dayKey: WeekProgress.dayKey,
          onSelect: controller.selectDay,
        );
      },
    );
  }
}
