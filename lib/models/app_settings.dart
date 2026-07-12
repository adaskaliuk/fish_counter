import 'package:fish_counter/models/athlete_profile.dart';
import 'package:fish_counter/utils/type_utils.dart';

class AppSettings {
  const AppSettings({
    required this.syncHistoryEnabled,
    required this.resetDelay,
    required this.vibeInterval,
    required this.matchSeconds,
    required this.shakeUndoEnabled,
    required this.shakeSensitivity,
    required this.role,
    required this.athleteProfile,
    required this.updatedAt,
  });

  final bool syncHistoryEnabled;
  final int resetDelay;
  final int vibeInterval;
  final int matchSeconds;
  final bool shakeUndoEnabled;
  final String shakeSensitivity;
  final String role;
  final AthleteProfile athleteProfile;
  final String updatedAt;

  Map<String, dynamic> toJson() => {
    'syncHistoryEnabled': syncHistoryEnabled,
    'resetDelay': resetDelay,
    'vibeInterval': vibeInterval,
    'matchSeconds': matchSeconds,
    'shakeUndoEnabled': shakeUndoEnabled,
    'shakeSensitivity': shakeSensitivity,
    'role': role,
    'athleteProfile': athleteProfile.toJson(),
    'updatedAt': updatedAt,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final rawProfile = json['athleteProfile'];
    return AppSettings(
      syncHistoryEnabled: TypeUtils.safeBool(json['syncHistoryEnabled']),
      resetDelay: TypeUtils.safeInt(json['resetDelay']),
      vibeInterval: TypeUtils.safeInt(json['vibeInterval']),
      matchSeconds: TypeUtils.safeInt(json['matchSeconds']),
      shakeUndoEnabled: TypeUtils.safeBool(json['shakeUndoEnabled'], defaultValue: true),
      shakeSensitivity: json['shakeSensitivity']?.toString() ?? 'medium',
      role: json['role']?.toString() ?? '',
      athleteProfile: rawProfile is Map
          ? AthleteProfile.fromJson(Map<String, dynamic>.from(rawProfile))
          : const AthleteProfile(),
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}
