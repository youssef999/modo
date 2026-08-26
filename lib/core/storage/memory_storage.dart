import 'i_storage.dart';

class MemoryStorage implements IStorage {
  final Map<String, dynamic> _data = {};

  @override
  T? read<T>(String key) {
    final value = _data[key];
    return value is T ? value : null;
  }

  @override
  Future<void> write(String key, dynamic value) async {
    _data[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _data.remove(key);
  }
}
