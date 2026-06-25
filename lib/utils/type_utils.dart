import 'dart:typed_data';

/// Utility class for safe type conversions and validation.
class TypeUtils {
  TypeUtils._();

  /// Safely converts a dynamic value to String.
  static String safeString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  /// Safely converts a dynamic value to int.
  static int safeInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? defaultValue;
  }

  /// Safely converts a dynamic value to double.
  static double? safeDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  /// Safely converts a dynamic value to bool.
  static bool safeBool(dynamic value, {bool defaultValue = false}) {
    if (value is bool) return value;
    return defaultValue;
  }

  /// Safely converts a dynamic value to List<Map<String, dynamic>>.
  static List<Map<String, dynamic>> safeMapList(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];

    return value
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }

  /// Safely trims a string and returns empty string if null.
  static String safeTrim(String? value) {
    return value?.trim() ?? '';
  }
}