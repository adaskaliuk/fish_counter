import 'package:fish_counter/models/athlete_profile.dart';

class AppSettings {
  const AppSettings({
    required this.syncHistoryEnabled,
    required this.resetDelay,
    required this.vibeInterval,
    required this.matchSeconds,
    required this.shakeUndoEnabled,
    required this.shakeSensitivity,
    required this.athleteProfile,
    required this.updatedAt,
  });

  final bool syncHistoryEnabled;
  final int resetDelay;
  final int vibeInterval;
  final int matchSeconds;
  final bool shakeUndoEnabled;
  final String shakeSensitivity;
  final AthleteProfile athleteProfile;
  final String updatedAt;

  Map<String, dynamic> toJson() => {
    'syncHistoryEnabled': syncHistoryEnabled,
    'resetDelay': resetDelay,
    'vibeInterval': vibeInterval,
    'matchSeconds': matchSeconds,
    'shakeUndoEnabled': shakeUndoEnabled,
    'shakeSensitivity': shakeSensitivity,
    'athleteProfile': athleteProfile.toJson(),
    'updatedAt': updatedAt,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final rawProfile = json['athleteProfile'];
    return AppSettings(
      syncHistoryEnabled: _bool(json['syncHistoryEnabled']),
      resetDelay: _int(json['resetDelay']),
      vibeInterval: _int(json['vibeInterval']),
      matchSeconds: _int(json['matchSeconds']),
      shakeUndoEnabled: _bool(json['shakeUndoEnabled'], defaultValue: true),
      shakeSensitivity: json['shakeSensitivity']?.toString() ?? 'medium',
      athleteProfile: rawProfile is Map
          ? AthleteProfile.fromJson(Map<String, dynamic>.from(rawProfile))
          : const AthleteProfile(),
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  static bool _bool(dynamic value, {bool defaultValue = false}) {
    if (value is bool) return value;
    return defaultValue;
  }

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
