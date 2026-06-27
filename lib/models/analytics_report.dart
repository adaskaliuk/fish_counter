import 'package:fish_counter/constants.dart';

class AnalyticsReport {
  final int greenCount;
  final int orangeCount;
  final int redCount;
  final int greyCount;
  final int tryCount;
  final int earlyCount;
  final int lateCount;
  final int? bestIntervalSeconds;
  final int? worstIntervalSeconds;
  final double averageInterval;
  final double averageDeviation;
  final int stabilityScore;
  final int longestStableStreak;

  const AnalyticsReport({
    required this.greenCount,
    required this.orangeCount,
    required this.redCount,
    required this.greyCount,
    required this.tryCount,
    required this.earlyCount,
    required this.lateCount,
    required this.bestIntervalSeconds,
    required this.worstIntervalSeconds,
    required this.averageInterval,
    required this.averageDeviation,
    required this.stabilityScore,
    required this.longestStableStreak,
  });

  int get validClickCount => greenCount + orangeCount + redCount + greyCount;

  static AnalyticsReport fromGrid(List<Map<String, dynamic>> grid) {
    var greenCount = 0;
    var orangeCount = 0;
    var redCount = 0;
    var greyCount = 0;
    var tryCount = 0;
    var intervalSum = 0.0;
    var deviationSum = 0.0;
    var scoreSum = 0;
    var longestStableStreak = 0;
    var currentStableStreak = 0;
    int? bestInterval;
    int? worstInterval;

    for (final entry in grid) {
      final type = _toInt(entry['type']);
      if (type == ActivityType.manualPause.value) continue;

      if (type == ActivityType.tryClick.value) {
        tryCount++;
      }

      final interval = _toInt(entry['interval']);
      final target = _toInt(
        entry['target'],
        defaultValue: Defaults.defaultVibeIntervalSeconds,
      );
      final status = _statusFromRaw(entry['status']);

      intervalSum += interval;
      deviationSum += interval - target;
      bestInterval = bestInterval == null || interval < bestInterval
          ? interval
          : bestInterval;
      worstInterval = worstInterval == null || interval > worstInterval
          ? interval
          : worstInterval;

      switch (status) {
        case Status.perfect:
          greenCount++;
          scoreSum += 100;
          currentStableStreak++;
          break;
        case Status.average:
        case Status.good:
          orangeCount++;
          scoreSum += 70;
          currentStableStreak++;
          break;
        case Status.poor:
          redCount++;
          scoreSum += 20;
          currentStableStreak = 0;
          break;
        case Status.early:
          greyCount++;
          scoreSum += 30;
          currentStableStreak = 0;
          break;
        case Status.pause:
          currentStableStreak = 0;
          break;
      }

      if (currentStableStreak > longestStableStreak) {
        longestStableStreak = currentStableStreak;
      }
    }

    final validCount = greenCount + orangeCount + redCount + greyCount;

    return AnalyticsReport(
      greenCount: greenCount,
      orangeCount: orangeCount,
      redCount: redCount,
      greyCount: greyCount,
      tryCount: tryCount,
      earlyCount: greyCount,
      lateCount: redCount,
      bestIntervalSeconds: bestInterval,
      worstIntervalSeconds: worstInterval,
      averageInterval: validCount == 0 ? 0 : intervalSum / validCount,
      averageDeviation: validCount == 0 ? 0 : deviationSum / validCount,
      stabilityScore: validCount == 0 ? 0 : (scoreSum / validCount).round(),
      longestStableStreak: longestStableStreak,
    );
  }

  static Status _statusFromRaw(dynamic value) {
    final raw = value?.toString();
    switch (raw) {
      case 'green':
        return Status.perfect;
      case 'red':
        return Status.poor;
      case 'grey':
        return Status.early;
      case 'orange':
        return Status.average;
      default:
        return Status.fromName(raw);
    }
  }

  static int _toInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? defaultValue;
  }

}
