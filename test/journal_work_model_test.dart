import 'package:flutter_test/flutter_test.dart';
import 'package:life_daily_app/features/journal/models/journal_entry.dart';
import 'package:life_daily_app/features/work/models/work_item.dart';

void main() {
  test('journal groupByDay keeps several snippets on the same day', () {
    final morning = JournalEntry(
      id: '1',
      ownerId: 'u',
      title: 'Morning',
      body: 'Light',
      day: '2026-08-24',
      folderId: 'general',
      createdAt: DateTime(2026, 8, 24, 8),
      updatedAt: DateTime(2026, 8, 24, 8),
    );
    final night = JournalEntry(
      id: '2',
      ownerId: 'u',
      title: 'Night',
      body: 'Quiet',
      day: '2026-08-24',
      folderId: 'general',
      createdAt: DateTime(2026, 8, 24, 21),
      updatedAt: DateTime(2026, 8, 24, 21),
    );
    final grouped = JournalEntry.groupByDay([morning, night]);
    expect(grouped['2026-08-24'], hasLength(2));
    expect(grouped['2026-08-24']!.first.body, 'Quiet');
  });

  test('work done items leave the open list', () {
    final open = WorkItem(
      id: '1',
      ownerId: 'u',
      title: 'Ship',
      details: 'Ship the build',
      folderId: 'general',
      status: WorkStatus.open,
      createdAt: DateTime(2026, 8, 24),
      updatedAt: DateTime(2026, 8, 24),
    );
    final done = open.copyWith(status: WorkStatus.done);
    expect(open.isDone, isFalse);
    expect(done.isDone, isTrue);
  });
}
