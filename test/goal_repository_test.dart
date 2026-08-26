import 'package:flutter_test/flutter_test.dart';
import 'package:life_daily_app/core/storage/memory_storage.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';
import 'package:life_daily_app/features/goals/repositories/cached_goal_repository.dart';
import 'package:life_daily_app/features/goals/repositories/local_goal_repository.dart';

void main() {
  test(
    'goals stay on disk after a new session and a new anonymous id',
    () async {
      final storage = MemoryStorage();
      final first = LocalGoalRepository(storage);
      await first.create(
        ownerId: 'anon-1',
        title: 'Gym',
        details: '',
        kind: GoalKind.habit,
        startsAt: DateTime(2026, 8, 1),
        dueAt: DateTime(2026, 8, 31),
        category: 'healthy_routine',
      );

      final second = LocalGoalRepository(storage);
      final goals = await second.fetch('anon-2');
      expect(goals, hasLength(1));
      expect(goals.first.title, 'Gym');
      expect(goals.first.ownerId, 'anon-2');
    },
  );

  test('cached repository writes locally even when cloud is off', () async {
    final storage = MemoryStorage();
    var cloud = false;
    final repository = CachedGoalRepository(
      local: LocalGoalRepository(storage),
      isCloudEnabled: () => cloud,
    );

    await repository.create(
      ownerId: 'local-dev-uid',
      title: 'Read',
      details: '',
      kind: GoalKind.once,
      startsAt: DateTime(2026, 8, 20),
      dueAt: DateTime(2026, 8, 20),
      category: 'course',
    );

    final reopened = CachedGoalRepository(
      local: LocalGoalRepository(storage),
      isCloudEnabled: () => cloud,
    );
    final goals = await reopened.fetch('local-dev-uid');
    expect(goals, hasLength(1));
    expect(goals.first.title, 'Read');
  });
}
