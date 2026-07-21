import 'package:fish_counter/services/local_storage.dart';
import 'package:fish_counter/services/prefs_repository.dart';

class MemoryLocalStorage implements LocalStorage {
  final Map<String, Object?> _values = {};

  Map<String, Object?> get values => Map.unmodifiable(_values);

  void seed(Map<String, Object?> values) {
    _values.addAll(values);
  }

  @override
  int? getInt(String key) => _values[key] is int ? _values[key] as int : null;

  @override
  bool? getBool(String key) =>
      _values[key] is bool ? _values[key] as bool : null;

  @override
  String? getString(String key) =>
      _values[key] is String ? _values[key] as String : null;

  @override
  List<String>? getStringList(String key) {
    final value = _values[key];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return null;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _values[key] = List<String>.from(value);
    return true;
  }

  @override
  Future<bool> clear() async {
    _values.clear();
    return true;
  }
}

Future<MemoryLocalStorage> useMemoryStorage() async {
  final storage = MemoryLocalStorage();
  PrefsRepository.useTestStorage(storage);
  return storage;
}

Future<MemoryLocalStorage> useSeededMemoryStorage(
  Map<String, Object?> values,
) async {
  final storage = MemoryLocalStorage()..seed(values);
  PrefsRepository.useTestStorage(storage);
  return storage;
}

Future<void> resetMemoryStorage() async {
  PrefsRepository.useTestStorage(null);
}
