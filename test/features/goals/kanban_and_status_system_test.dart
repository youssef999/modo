import 'package:flutter_test/flutter_test.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';
import 'package:life_daily_app/features/goals/models/goal_task.dart';

void main() {
  group('GoalStatus & TaskStatus Notion-Surpassing System Tests', () {
    test('GoalStatus backward compatibility: "active" maps to notStarted, "done" to done', () {
      final now = DateTime(2026, 9, 20);
      final rawMapLegacy = {
        'id': 'g1',
        'ownerId': 'user1',
        'title': 'Build Mobile App',
        'details': '',
        'kind': 'once',
        'startsAt': now.toIso8601String(),
        'dueAt': now.toIso8601String(),
        'category': 'startup',
        'status': 'active', // legacy status from older schema
        'checkIns': <String>[],
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'tasks': [
          {
            'id': 't1',
            'title': 'Design UI',
            'isCompleted': true, // legacy boolean
            'order': 0,
          },
          {
            'id': 't2',
            'title': 'Implement Auth',
            'status': 'inProgress', // new status
            'order': 1,
          },
          {
            'id': 't3',
            'title': 'Write Tests',
            'status': 'todo',
            'order': 2,
          },
        ],
        'trackers': <Map<String, dynamic>>[],
      };

      final goal = GoalModel.fromMap('g1', rawMapLegacy);

      // Verify GoalStatus mapped from 'active' to notStarted
      expect(goal.status, GoalStatus.notStarted);
      expect(goal.isActive, isTrue);
      expect(goal.isDone, isFalse);
      expect(goal.isArchived, isFalse);

      // Verify TaskStatus backward compatibility
      expect(goal.tasks[0].status, GoalTaskStatus.done);
      expect(goal.tasks[0].isCompleted, isTrue);

      expect(goal.tasks[1].status, GoalTaskStatus.inProgress);
      expect(goal.tasks[1].isCompleted, isFalse);

      expect(goal.tasks[2].status, GoalTaskStatus.todo);
      expect(goal.tasks[2].isCompleted, isFalse);

      expect(goal.completedTasksCount, 1);
    });

    test('GoalModel supports all 4 statuses: notStarted, inProgress, done, archived', () {
      final now = DateTime(2026, 9, 20);
      final base = GoalModel(
        id: 'g2',
        ownerId: 'user1',
        title: 'Launch Marketing Campaign',
        details: 'Social media & PR',
        kind: GoalKind.once,
        startsAt: now,
        dueAt: now,
        category: 'marketing',
        status: GoalStatus.notStarted,
        checkIns: const [],
        createdAt: now,
        updatedAt: now,
      );

      final inProg = base.copyWith(status: GoalStatus.inProgress);
      expect(inProg.status, GoalStatus.inProgress);
      expect(inProg.isActive, isTrue);

      final done = base.copyWith(status: GoalStatus.done);
      expect(done.status, GoalStatus.done);
      expect(done.isDone, isTrue);
      expect(done.isFullyComplete, isTrue);

      final archived = base.copyWith(status: GoalStatus.archived);
      expect(archived.status, GoalStatus.archived);
      expect(archived.isArchived, isTrue);
      expect(archived.isFullyComplete, isTrue);
    });

    test('Task creation and status modification with TaskStatus', () {
      final task = const GoalTask(
        id: 'task_new',
        title: 'Create Notion Kanban',
        status: GoalTaskStatus.inProgress,
      );

      expect(task.status, GoalTaskStatus.inProgress);
      expect(task.isCompleted, isFalse);

      final completedTask = task.copyWith(status: GoalTaskStatus.done);
      expect(completedTask.status, GoalTaskStatus.done);
      expect(completedTask.isCompleted, isTrue);

      // Serialization check
      final map = completedTask.toMap();
      expect(map['status'], 'done');
      expect(GoalTask.fromMap(map).status, GoalTaskStatus.done);
    });
  });
}
