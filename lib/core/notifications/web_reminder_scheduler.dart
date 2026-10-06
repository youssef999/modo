import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'i_reminder_scheduler.dart';

/// Browser notifications. Browsers can't wake a closed tab without push,
/// so the reminder only fires while the app tab is open.
class WebReminderScheduler implements IReminderScheduler {
  final Map<int, Timer> _timers = {};

  bool get _supported => globalContext.has('Notification');

  bool get _granted => _supported && web.Notification.permission == 'granted';

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async {
    if (!_supported) return false;
    if (_granted) return true;
    if (web.Notification.permission == 'denied') return false;
    try {
      final result = await web.Notification.requestPermission().toDart;
      return result.toDart == 'granted';
    } catch (error) {
      debugPrint('Notification permission failed: $error');
      return false;
    }
  }

  @override
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String channelName,
  }) async {
    await cancel(id);
    if (!_supported) return;
    final delay = nextDailyOccurrence(
      DateTime.now(),
      hour,
      minute,
    ).difference(DateTime.now());
    _timers[id] = Timer(delay, () {
      _show(title, body);
      scheduleDaily(
        id: id,
        title: title,
        body: body,
        hour: hour,
        minute: minute,
        channelName: channelName,
      );
    });
  }

  @override
  Future<void> cancel(int id) async {
    _timers.remove(id)?.cancel();
  }

  void _show(String title, String body) {
    if (!_granted) return;
    try {
      web.Notification(
        title,
        web.NotificationOptions(body: body, icon: 'icons/Icon-192.png'),
      );
    } catch (error) {
      debugPrint('Notification show failed: $error');
    }
  }
}
