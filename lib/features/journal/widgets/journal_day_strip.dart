import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/features/journal/controllers/journal_controller.dart';
import 'package:life_daily_app/features/journal/models/journal_entry.dart';
import 'package:life_daily_app/shared/widgets/layout/app_day_strip.dart';

class JournalDayStrip extends StatelessWidget {
  const JournalDayStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<JournalController>(
      id: 'journal',
      builder: (controller) {
        return AppDayStrip(
          days: controller.nearbyDays(),
          selectedKey: controller.selectedDayKey,
          dayKey: JournalEntry.dayKey,
          onSelect: controller.selectDay,
        );
      },
    );
  }
}
