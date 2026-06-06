// lib/constants.dart
// This file centralizes all global constants and keys.
import 'package:flutter/material.dart';

// --- SharedPreferences Keys ---
class PrefsKeys {
  // Counters and Status
  static const String counter1 = 'counter1';
  static const String counter2 = 'counter2';
  static const String tries = 'tries';
  static const String total = 'total';

  // Operational Status
  static const String isPowerOn = 'power';
  static const String isPaused = 'paused';
  static const String isSessionActive = 'is_session_active';
  static const String isDataHidden = 'is_data_hidden';

  // Timers & Intervals
  static const String resetDelay = 'reset_delay'; // Seconds for delay countdown
  static const String vibeInterval =
      'vibe_interval'; // Period for vibration feedback
  static const String matchSeconds =
      'match_seconds'; // Total match duration in seconds

  // Undo
  static const String shakeUndoEnabled = 'shake_undo_enabled';
  static const String shakeSensitivity = 'shake_sensitivity';

  // Grid/History
  static const String activityGrid = 'activity_grid_final';
  static const String historySessions = 'history_sessions';
}

// --- Default Values ---
class Defaults {
  static const int defaultResetDelaySeconds = 15;
  static const int defaultVibeIntervalSeconds = 60;
  static const int defaultMatchDurationSeconds = 18000; // 5 hours
  static const int defaultActivityDelayMs = 600;
  static const int defaultScrollDelayMs = 100;
  static const bool defaultShakeUndoEnabled = true;
  static const String defaultShakeSensitivity = 'medium';
}

// --- Enum Definitions ---

/// Defines the possible actions/types recorded in the activity grid.
enum ActivityType {
  c1Click(1),
  c2Click(2),
  tryClick(3),
  manualPause(0),
  unknown(-1);

  final int value;
  const ActivityType(this.value);

  static ActivityType fromValue(int value) {
    return ActivityType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ActivityType.unknown,
    );
  }
}

/// Defines the feedback status of a click relative to the target interval.
enum Status {
  perfect(1.0), // Green
  good(0.8), // Orange-Green
  average(1.0), // Orange
  poor(1.5), // Red-ish
  early(0.5), // Grey
  pause(0.0); // Grey/Neutral

  final double multiplier; // Relative to target
  const Status(this.multiplier);

  static Status fromName(String? name) {
    switch (name) {
      case 'green':
        return Status.perfect;
      case 'red':
        return Status.poor;
      case 'grey':
        return Status.early;
      case 'orange':
        return Status.average;
    }

    return Status.values.firstWhere(
      (status) => status.name == name,
      orElse: () => Status.average,
    );
  }

  /// Maps the status enum to a comparable color.
  Color toColor() {
    switch (this) {
      case Status.perfect:
        return Colors.green.shade900;
      case Status.good:
        return Colors.green.shade600;
      case Status.average:
        return Colors.orange.shade900;
      case Status.poor:
        return Colors.red.shade900;
      case Status.early:
        return Colors.grey.shade700;
      case Status.pause:
        return Colors.grey.shade500;
    }
  }
}
