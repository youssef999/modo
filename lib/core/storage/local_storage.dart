import 'package:get_storage/get_storage.dart';

import 'i_storage.dart';

class LocalStorage implements IStorage {
  LocalStorage({GetStorage? box}) : _box = box ?? GetStorage();

  final GetStorage _box;

  @override
  T? read<T>(String key) => _box.read<T>(key);

  @override
  Future<void> write(String key, dynamic value) => _box.write(key, value);

  @override
  Future<void> remove(String key) => _box.remove(key);
}
