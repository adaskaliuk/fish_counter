import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:hive_ce/hive_ce.dart';

import 'hive_path_resolver.dart';

abstract interface class LocalStorage {
  int? getInt(String key);
  bool? getBool(String key);
  String? getString(String key);
  List<String>? getStringList(String key);

  Future<bool> setInt(String key, int value);
  Future<bool> setBool(String key, bool value);
  Future<bool> setString(String key, String value);
  Future<bool> setStringList(String key, List<String> value);
  Future<bool> clear();
}

class HiveLocalStorage implements LocalStorage {
  static const _boxName = 'fish_counter_local';
  static bool _initialized = false;
  static Future<HiveLocalStorage>? _instanceFuture;
  static String? _testBasePath;

  final Box<dynamic> _box;

  HiveLocalStorage._(this._box);

  static Future<HiveLocalStorage> create() async {
    final existing = _instanceFuture;
    if (existing != null) return existing;

    final future = _create();
    _instanceFuture = future;
    return future;
  }

  static Future<HiveLocalStorage> _create() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (!kIsWeb && !_initialized) {
      final basePath = _testBasePath ?? await resolveHiveBasePath();
      if (basePath != null) {
        Hive.init(basePath);
      }
      _initialized = true;
    }

    final box = await Hive.openBox<dynamic>(_boxName);
    return HiveLocalStorage._(box);
  }

  static Future<void> resetForTests() async {
    final existing = _instanceFuture;
    _instanceFuture = null;
    _initialized = false;
    if (existing != null) {
      final instance = await existing;
      await instance._box.close();
    }
  }

  static Future<void> useTestBasePath(String basePath) async {
    _testBasePath = basePath;
    await resetForTests();
  }

  @override
  int? getInt(String key) {
    final value = _box.get(key);
    return value is int ? value : null;
  }

  @override
  bool? getBool(String key) {
    final value = _box.get(key);
    return value is bool ? value : null;
  }

  @override
  String? getString(String key) {
    final value = _box.get(key);
    return value is String ? value : null;
  }

  @override
  List<String>? getStringList(String key) {
    final value = _box.get(key);
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return null;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    await _box.put(key, value);
    return true;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    await _box.put(key, value);
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    await _box.put(key, value);
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    final copy = List<String>.from(value);
    await _box.put(key, copy);
    return true;
  }

  @override
  Future<bool> clear() async {
    await _box.clear();
    return true;
  }
}
