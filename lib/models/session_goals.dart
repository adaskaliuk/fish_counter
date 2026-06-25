import 'package:fish_counter/utils/type_utils.dart';

/// Goal settings for a game session.
class SessionGoals {
  final int goalFishCount;
  final int goalTargetPaceSeconds;
  final int goalMaxTries;
  final int goalStabilityPercent;

  const SessionGoals({
    this.goalFishCount = 0,
    this.goalTargetPaceSeconds = 0,
    this.goalMaxTries = 0,
    this.goalStabilityPercent = 0,
  });

  Map<String, dynamic> toJson() => {
    'goalFishCount': goalFishCount,
    'goalTargetPaceSeconds': goalTargetPaceSeconds,
    'goalMaxTries': goalMaxTries,
    'goalStabilityPercent': goalStabilityPercent,
  };

  factory SessionGoals.fromJson(Map<String, dynamic> json) {
    return SessionGoals(
      goalFishCount: TypeUtils.safeInt(json['goalFishCount']),
      goalTargetPaceSeconds: TypeUtils.safeInt(json['goalTargetPaceSeconds']),
      goalMaxTries: TypeUtils.safeInt(json['goalMaxTries']),
      goalStabilityPercent: TypeUtils.safeInt(json['goalStabilityPercent']),
    );
  }
}