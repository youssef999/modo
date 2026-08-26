import 'package:flutter_test/flutter_test.dart';
import 'package:life_daily_app/core/storage/memory_storage.dart';
import 'package:life_daily_app/features/work/models/work_item.dart';
import 'package:life_daily_app/features/work/repositories/cached_work_repository.dart';
import 'package:life_daily_app/features/work/repositories/local_work_repository.dart';

void main() {
  test(
    'work stays on disk after a new session and a new anonymous id',
    () async {
      final storage = MemoryStorage();
      final first = LocalWorkRepository(storage);
      final created = await first.create(
        ownerId: 'anon-1',
        title: 'Ship build',
        details: 'Release notes',
        folderId: 'general',
      );
      await first.update(created.copyWith(status: WorkStatus.done));

      final second = LocalWorkRepository(storage);
      final items = await second.fetch('anon-2');
      expect(items, hasLength(1));
      expect(items.first.title, 'Ship build');
      expect(items.first.ownerId, 'anon-2');
      expect(items.first.isDone, isTrue);
    },
  );

  test('create then complete leaves open empty and done filled', () async {
    final storage = MemoryStorage();
    final repository = CachedWorkRepository(
      local: LocalWorkRepository(storage),
      isCloudEnabled: () => false,
    );
    final item = await repository.create(
      ownerId: 'local-dev-uid',
      title: 'Review PR',
      details: 'Check tests and copy',
      folderId: 'general',
    );
    expect(item.status, WorkStatus.open);
    await repository.update(item.copyWith(status: WorkStatus.done));
    final items = await repository.fetch('local-dev-uid');
    expect(items.where((entry) => !entry.isDone), isEmpty);
    expect(
      items.where((entry) => entry.isDone).first.details,
      'Check tests and copy',
    );
  });

  test('empty folders still include general', () async {
    final storage = MemoryStorage();
    final repository = LocalWorkRepository(storage);
    final folders = await repository.fetchFolders('uid-1');
    expect(folders.any((folder) => folder.id == 'general'), isTrue);
  });

  test('new task keeps folderId', () async {
    final storage = MemoryStorage();
    final repository = LocalWorkRepository(storage);
    await repository.fetchFolders('uid-1');
    final folder = await repository.addFolder(ownerId: 'uid-1', name: 'Office');
    final item = await repository.create(
      ownerId: 'uid-1',
      title: 'Call',
      details: 'Client',
      folderId: folder.id,
    );
    expect(item.folderId, folder.id);
    final items = await repository.fetch('uid-1');
    expect(items.where((entry) => entry.folderId == folder.id), hasLength(1));
  });
}
