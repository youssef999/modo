import 'package:flutter_test/flutter_test.dart';
import 'package:life_daily_app/core/utils/week_progress.dart';

void main() {
  test('week progress counts this week and a consecutive streak', () {
    final now = DateTime(2026, 8, 24);
    expect(WeekProgress.inWeek(DateTime(2026, 8, 24), now), isTrue);
    expect(WeekProgress.inWeek(DateTime(2026, 8, 16), now), isFalse);
    expect(
      WeekProgress.streakDays({'2026-08-24', '2026-08-23', '2026-08-21'}, now),
      2,
    );
    const progress = WeekProgress(done: 2, total: 4, streak: 2);
    expect(progress.percent, 50);
  });
}
