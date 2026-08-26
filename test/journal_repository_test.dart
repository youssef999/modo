import 'package:flutter_test/flutter_test.dart';
import 'package:life_daily_app/core/storage/memory_storage.dart';
import 'package:life_daily_app/features/journal/models/journal_entry.dart';
import 'package:life_daily_app/features/journal/repositories/cached_journal_repository.dart';
import 'package:life_daily_app/features/journal/repositories/local_journal_repository.dart';

void main() {
  test('journal stays on disk and groups by day', () async {
    final storage = MemoryStorage();
    final first = LocalJournalRepository(storage);
    await first.create(
      ownerId: 'anon-1',
      title: 'Morning',
      body: 'Light',
      day: '2026-08-24',
      folderId: 'general',
    );
    await first.create(
      ownerId: 'anon-1',
      title: 'Night',
      body: 'Quiet',
      day: '2026-08-24',
      folderId: 'general',
    );
    await first.create(
      ownerId: 'anon-1',
      title: 'Yesterday',
      body: 'Walk',
      day: '2026-08-23',
      folderId: 'general',
    );

    final second = LocalJournalRepository(storage);
    final items = await second.fetch('anon-2');
    expect(items, hasLength(3));
    expect(items.first.ownerId, 'anon-2');
    final grouped = JournalEntry.groupByDay(items);
    expect(grouped['2026-08-24'], hasLength(2));
    expect(grouped['2026-08-23'], hasLength(1));
  });

  test('cached journal writes locally even when cloud is off', () async {
    final storage = MemoryStorage();
    final repository = CachedJournalRepository(
      local: LocalJournalRepository(storage),
      isCloudEnabled: () => false,
    );
    await repository.create(
      ownerId: 'local-dev-uid',
      title: 'A line',
      body: 'Longer details for the day',
      day: JournalEntry.dayKey(DateTime(2026, 8, 24)),
      folderId: 'general',
    );
    final reopened = CachedJournalRepository(
      local: LocalJournalRepository(storage),
      isCloudEnabled: () => false,
    );
    final items = await reopened.fetch('local-dev-uid');
    expect(items, hasLength(1));
    expect(items.first.title, 'A line');
    expect(items.first.body, 'Longer details for the day');
    expect(items.first.day, '2026-08-24');
  });

  test('empty folders still include general', () async {
    final storage = MemoryStorage();
    final repository = LocalJournalRepository(storage);
    final folders = await repository.fetchFolders('uid-1');
    expect(folders.any((folder) => folder.id == 'general'), isTrue);
  });

  test('new note keeps folderId', () async {
    final storage = MemoryStorage();
    final repository = LocalJournalRepository(storage);
    await repository.fetchFolders('uid-1');
    final folder = await repository.addFolder(ownerId: 'uid-1', name: 'Travel');
    final entry = await repository.create(
      ownerId: 'uid-1',
      title: 'Airport',
      body: 'Late flight',
      day: '2026-08-24',
      folderId: folder.id,
    );
    expect(entry.folderId, folder.id);
    final items = await repository.fetch('uid-1');
    expect(items.where((item) => item.folderId == folder.id), hasLength(1));
  });
}
