import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/constants/storage_keys.dart';
import 'package:life_daily_app/core/notifications/i_reminder_scheduler.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';
import 'package:life_daily_app/features/auth/controllers/profile_controller.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';

/// Schedules one daily progress reminder at 9:00 PM.
/// Scheduled text is fixed once queued, so [reschedule] re-queues it whenever
/// goals change to keep the numbers current.
class DailyReminderController extends GetxController {
  DailyReminderController(this._storage, this._scheduler);

  final IStorage _storage;
  final IReminderScheduler _scheduler;

  static const int reminderId = 2100;
  static const int hour = 21;
  static const int minute = 0;

  bool enabled = false;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    // Browsers only show the permission prompt after a user tap, so web
    // starts off and turns on from the drawer switch.
    enabled = _storage.read<bool>(StorageKeys.dailyReminderEnabled) ?? !kIsWeb;
    if (enabled) _start();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> _start() async {
    final granted = await _scheduler.requestPermission();
    if (!granted && kIsWeb) {
      enabled = false;
      update(['reminder']);
      return;
    }
    await reschedule();
  }

  Future<void> setEnabled(bool value) async {
    if (value == enabled) return;
    if (value) {
      final granted = await _scheduler.requestPermission();
      if (!granted) {
        enabled = false;
        update(['reminder']);
        return;
      }
    }
    enabled = value;
    await _storage.write(StorageKeys.dailyReminderEnabled, value);
    update(['reminder']);
    if (value) {
      await reschedule();
    } else {
      await _scheduler.cancel(reminderId);
    }
  }

  /// Debounced so bulk goal edits re-queue the reminder once.
  void scheduleRefresh() {
    if (!enabled) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), reschedule);
  }

  Future<void> reschedule() async {
    if (!enabled) return;
    try {
      await _scheduler.scheduleDaily(
        id: reminderId,
        title: _title(),
        body: _body(),
        hour: hour,
        minute: minute,
        channelName: LocaleKeys.reminderChannel.tr,
      );
    } catch (error) {
      debugPrint('Daily reminder schedule failed: $error');
    }
  }

  String _title() {
    final name = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>().displayName.trim()
        : '';
    if (name.isEmpty) return LocaleKeys.dailyReminder.tr;
    return LocaleKeys.reminderTitle.trParams({'name': name});
  }

  String _body() {
    if (!Get.isRegistered<GoalsController>()) {
      return LocaleKeys.reminderBodyEmpty.tr;
    }
    final goals = Get.find<GoalsController>();
    final today = goals.dailyProgress(DateTime.now());
    var openTasks = 0;
    for (final goal in goals.goals) {
      if (goal.isArchived) continue;
      openTasks += goal.tasks.where((task) => !task.isCompleted).length;
    }
    if (today.total == 0 && openTasks == 0 && goals.realGoals.isEmpty) {
      return LocaleKeys.reminderBodyEmpty.tr;
    }
    return LocaleKeys.reminderBody.trParams({
      'done': '${today.completed}',
      'total': '${today.total}',
      'open': '$openTasks',
      'percent': '${goals.progressPercent}',
    });
  }
}
