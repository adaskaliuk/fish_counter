// ==========================================
// ACTIVITY MODEL
// ==========================================

import 'package:fish_counter/constants.dart';

/// Represents a single click/action entry in the activity timeline.
class ActivityLog {
  final ActivityType type;
  final Status status;
  final Duration interval;
  final int targetInterval;
  final String timestamp;

  ActivityLog({
    required this.type,
    required this.status,
    required this.interval,
    required this.targetInterval,
    required this.timestamp,
  });

  factory ActivityLog.fromRawData({
    required ActivityType type,
    required Status status,
    required int intervalSeconds,
    required int targetInterval,
    required String timestampString,
  }) {
    return ActivityLog(
      type: type,
      status: status,
      interval: Duration(seconds: intervalSeconds),
      targetInterval: targetInterval,
      timestamp: timestampString,
    );
  }

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      type: ActivityType.fromValue(_safeInt(json['type'])),
      status: Status.fromName(json['status']?.toString()),
      interval: Duration(seconds: _safeInt(json['interval'])),
      targetInterval: _safeInt(
        json['target'],
        defaultValue: Defaults.defaultVibeIntervalSeconds,
      ),
      timestamp: json['timestamp']?.toString() ?? '--:--:--',
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.value,
    'status': status.name,
    'interval': interval.inSeconds,
    'target': targetInterval,
    'timestamp': timestamp,
  };

  static int _safeInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? defaultValue;
  }
}
