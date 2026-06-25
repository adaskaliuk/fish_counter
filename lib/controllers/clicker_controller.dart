import 'package:fish_counter/constants.dart';
import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/models/session_goals.dart';
import 'package:fish_counter/models/session_user_info.dart';
import 'package:fish_counter/models/session_venue_info.dart';
import 'package:fish_counter/models/weather_info.dart';
import 'package:fish_counter/models/weather_snapshot.dart';
import 'package:flutter/foundation.dart';

@immutable
class ClickerCounters {
  final int counter1;
  final int counter2;
  final int tries;
  final int total;

  const ClickerCounters({
    required this.counter1,
    required this.counter2,
    required this.tries,
    required this.total,
  });
}

@immutable
class ClickerPowerState {
  final bool isPowerOn;
  final bool isPaused;
  final bool isSessionActive;
  final bool isDataHidden;
  final bool isActionDelay;
  final int delayCountdown;
  final Duration duration;
  final bool shouldResetCounters;
  final bool shouldClearActivity;
  final bool hasHistory;
  final Duration? matchInterval;

  const ClickerPowerState({
    required this.isPowerOn,
    required this.isPaused,
    required this.isSessionActive,
    required this.isDataHidden,
    required this.isActionDelay,
    required this.delayCountdown,
    required this.duration,
    required this.shouldResetCounters,
    required this.shouldClearActivity,
    required this.hasHistory,
    this.matchInterval,
  });
}

@immutable
class ClickerPauseState {
  final bool isSessionActive;
  final bool isPaused;
  final bool isDataHidden;
  final bool shouldResetDuration;
  final bool shouldAddPauseMarker;

  const ClickerPauseState({
    required this.isSessionActive,
    required this.isPaused,
    required this.isDataHidden,
    required this.shouldResetDuration,
    required this.shouldAddPauseMarker,
  });
}

/// Holds clicker business rules that are independent from Flutter UI widgets.
///
/// The full state is still owned by `ClickerScreen`; this controller is the
/// first step toward moving business logic out of the screen.
class ClickerController extends ChangeNotifier {
  static ClickerPowerState turnPowerOn() {
    return const ClickerPowerState(
      isPowerOn: true,
      isPaused: true,
      isSessionActive: false,
      isDataHidden: true,
      isActionDelay: false,
      delayCountdown: 0,
      duration: Duration.zero,
      shouldResetCounters: false,
      shouldClearActivity: false,
      hasHistory: false,
    );
  }

  static ClickerPowerState turnPowerOffWithoutSaving() {
    return const ClickerPowerState(
      isPowerOn: false,
      isPaused: true,
      isSessionActive: false,
      isDataHidden: true,
      isActionDelay: false,
      delayCountdown: 0,
      duration: Duration.zero,
      shouldResetCounters: false,
      shouldClearActivity: false,
      hasHistory: false,
    );
  }

  static GameSession buildSession({
    required String id,
    required String name,
    required String date,
    required int counter1,
    required int counter2,
    required int tries,
    required int total,
    required Duration matchInterval,
    required List<Map<String, dynamic>> activityGrid,
    String userId = '',
    String userEmail = '',
    String userDisplayName = '',
    String athleteName = '',
    String coachName = '',
    String venue = '',
    String sectorPeg = '',
    String trainingType = '',
    String fishingMethod = '',
    String targetPace = '',
    int goalFishCount = 0,
    int goalTargetPaceSeconds = 0,
    int goalMaxTries = 0,
    int goalStabilityPercent = 0,
    String conditions = '',
    String baitNotes = '',
    WeatherSnapshot? weather,
    String athleteNote = '',
    String coachComment = '',
  }) {
    final weatherInfo = weather != null
        ? WeatherInfo(
            place: weather.placeName,
            description: weather.description,
            fetchedAt: weather.fetchedAt,
            latitude: weather.latitude,
            longitude: weather.longitude,
            temperatureCelsius: weather.temperatureCelsius,
            feelsLikeCelsius: weather.feelsLikeCelsius,
            pressureHpa: weather.pressureHpa,
            humidityPercent: weather.humidityPercent,
            windSpeedMs: weather.windSpeedMs,
            windDirectionDegrees: weather.windDirectionDegrees,
          )
        : const WeatherInfo();

    return GameSession(
      id: id,
      name: name,
      date: date,
      c1: counter1,
      c2: counter2,
      tries: tries,
      total: total,
      matchDuration: formatMatchDuration(matchInterval),
      grid: List<Map<String, dynamic>>.from(activityGrid),
      athleteName: athleteName.trim(),
      coachName: coachName.trim(),
      weatherInfo: weatherInfo,
      athleteNote: athleteNote.trim(),
      coachComment: coachComment.trim(),
      userInfo: SessionUserInfo(
        userId: userId.trim(),
        userEmail: userEmail.trim(),
        userDisplayName: userDisplayName.trim(),
      ),
      venueInfo: SessionVenueInfo(
        venue: venue.trim(),
        sectorPeg: sectorPeg.trim(),
        trainingType: trainingType.trim(),
        fishingMethod: fishingMethod.trim(),
        targetPace: targetPace.trim(),
        conditions: conditions.trim(),
        baitNotes: baitNotes.trim(),
      ),
      goals: SessionGoals(
        goalFishCount: goalFishCount,
        goalTargetPaceSeconds: goalTargetPaceSeconds,
        goalMaxTries: goalMaxTries,
        goalStabilityPercent: goalStabilityPercent,
      ),
    );
  }

  static String formatMatchDuration(Duration duration) {
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    return '${duration.inHours}:$minutes';
  }

  static ClickerPowerState resetAfterSessionSaved() {
    return const ClickerPowerState(
      isPowerOn: false,
      isPaused: true,
      isSessionActive: false,
      isDataHidden: true,
      isActionDelay: false,
      delayCountdown: 0,
      duration: Duration.zero,
      shouldResetCounters: true,
      shouldClearActivity: true,
      hasHistory: true,
      matchInterval: Duration(seconds: Defaults.defaultMatchDurationSeconds),
    );
  }

  static bool canIncrement({
    required bool isPowerOn,
    required bool isActionDelay,
    required bool isPaused,
    required bool isSessionActive,
  }) {
    return isPowerOn && !isActionDelay && !isPaused && isSessionActive;
  }

  static ClickerCounters incrementCounters({
    required int counter1,
    required int counter2,
    required int tries,
    required int type,
  }) {
    var updatedCounter1 = counter1;
    var updatedCounter2 = counter2;
    var updatedTries = tries;

    switch (ActivityType.fromValue(type)) {
      case ActivityType.c1Click:
        updatedCounter1++;
      case ActivityType.c2Click:
        updatedCounter2++;
      case ActivityType.tryClick:
        updatedTries++;
      case ActivityType.manualPause:
      case ActivityType.unknown:
        break;
    }

    return ClickerCounters(
      counter1: updatedCounter1,
      counter2: updatedCounter2,
      tries: updatedTries,
      total: updatedCounter1 + updatedCounter2,
    );
  }

  static Map<String, dynamic> buildActivityEntry({
    required int type,
    required int intervalSeconds,
    required int targetInterval,
    required String timestamp,
  }) {
    return {
      'type': type,
      'status': calculateStatus(intervalSeconds, targetInterval),
      'interval': intervalSeconds,
      'target': targetInterval,
      'timestamp': timestamp,
    };
  }

  static Map<String, dynamic> buildPauseEntry({required String timestamp}) {
    return {
      'type': ActivityType.manualPause.value,
      'status': 'grey',
      'interval': 0,
      'timestamp': timestamp,
    };
  }

  static ClickerPauseState togglePause({
    required bool isSessionActive,
    required bool isPaused,
  }) {
    final nextPaused = !isPaused;

    return ClickerPauseState(
      isSessionActive: true,
      isPaused: nextPaused,
      isDataHidden: nextPaused,
      shouldResetDuration: nextPaused,
      shouldAddPauseMarker: nextPaused,
    );
  }

  static String calculateStatus(int seconds, int targetInterval) {
    if (targetInterval <= 0) return 'orange';

    if (seconds >= targetInterval * 0.9 && seconds <= targetInterval * 1.1) {
      return 'green';
    } else if (seconds < targetInterval * 0.7) {
      return 'grey';
    } else if (seconds > targetInterval * 1.5) {
      return 'red';
    } else {
      return 'orange';
    }
  }
}
