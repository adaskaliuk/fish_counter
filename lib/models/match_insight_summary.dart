import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/models/weather_snapshot.dart';

class MatchActivityWindow {
  const MatchActivityWindow({
    required this.startSeconds,
    required this.durationMinutes,
    required this.eventCount,
  });

  final int startSeconds;
  final int durationMinutes;
  final int eventCount;

  int get midpointSeconds => startSeconds + (durationMinutes * 60 ~/ 2);

  String get label {
    final endSeconds = startSeconds + durationMinutes * 60 - 1;
    return '${_formatClock(startSeconds)}–${_formatClock(endSeconds)}';
  }
}

class MatchInsightSummary {
  const MatchInsightSummary({
    required this.bestWindow,
    required this.quietestWindow,
    this.nearestWeather,
    this.nearestWeatherTimeLabel = '',
  });

  static const int defaultWindowMinutes = 5;

  final MatchActivityWindow bestWindow;
  final MatchActivityWindow quietestWindow;
  final WeatherSnapshot? nearestWeather;
  final String nearestWeatherTimeLabel;

  static MatchInsightSummary? fromSession(
    GameSession session, {
    List<WeatherSnapshot>? snapshots,
    int windowMinutes = defaultWindowMinutes,
  }) {
    if (windowMinutes <= 0) {
      throw ArgumentError.value(
        windowMinutes,
        'windowMinutes',
        'must be positive',
      );
    }

    final eventSeconds = _eventSeconds(session.grid);
    if (eventSeconds.isEmpty) return null;

    final windowSeconds = windowMinutes * 60;
    final firstStart =
        eventSeconds.reduce(_min) ~/ windowSeconds * windowSeconds;
    final lastStart =
        eventSeconds.reduce(_max) ~/ windowSeconds * windowSeconds;
    final counts = <int, int>{
      for (var start = firstStart; start <= lastStart; start += windowSeconds)
        start: 0,
    };

    for (final seconds in eventSeconds) {
      final start = seconds ~/ windowSeconds * windowSeconds;
      counts[start] = counts[start]! + 1;
    }

    final windows = counts.entries
        .map(
          (entry) => MatchActivityWindow(
            startSeconds: entry.key,
            durationMinutes: windowMinutes,
            eventCount: entry.value,
          ),
        )
        .toList();
    final bestWindow = windows.reduce(
      (best, candidate) =>
          candidate.eventCount > best.eventCount ? candidate : best,
    );
    final quietestWindow = windows.reduce(
      (quietest, candidate) =>
          candidate.eventCount < quietest.eventCount ? candidate : quietest,
    );
    final weather = _nearestWeather(
      snapshots ?? session.weatherSnapshots,
      bestWindow.midpointSeconds,
    );

    return MatchInsightSummary(
      bestWindow: bestWindow,
      quietestWindow: quietestWindow,
      nearestWeather: weather?.snapshot,
      nearestWeatherTimeLabel: weather == null
          ? ''
          : _formatClock(weather.secondsOfDay),
    );
  }
}

const int _secondsPerDay = 24 * 60 * 60;

List<int> _eventSeconds(List<Map<String, dynamic>> grid) {
  final result = <int>[];
  var dayOffset = 0;
  int? previous;

  for (final entry in grid) {
    final type = int.tryParse(entry['type']?.toString() ?? '') ?? 0;
    if (type == 0) continue;

    final rawSeconds = _parseClockSeconds(entry['timestamp']?.toString() ?? '');
    if (rawSeconds == null) continue;

    var normalized = rawSeconds + dayOffset;
    if (previous != null && previous - normalized > _secondsPerDay ~/ 2) {
      dayOffset += _secondsPerDay;
      normalized = rawSeconds + dayOffset;
    }
    previous = normalized;
    result.add(normalized);
  }

  return result;
}

_WeatherAtTime? _nearestWeather(
  List<WeatherSnapshot> snapshots,
  int targetSeconds,
) {
  _WeatherAtTime? nearest;
  var nearestDistance = _secondsPerDay;
  final target = targetSeconds % _secondsPerDay;

  for (final snapshot in snapshots) {
    final seconds = _parseClockSeconds(snapshot.fetchedAt);
    if (seconds == null) continue;
    final directDistance = (seconds - target).abs();
    final distance = _min(directDistance, _secondsPerDay - directDistance);
    if (distance < nearestDistance) {
      nearestDistance = distance;
      nearest = _WeatherAtTime(snapshot, seconds);
    }
  }

  return nearest;
}

int? _parseClockSeconds(String value) {
  final parsedDate = value.contains('T') ? DateTime.tryParse(value) : null;
  if (parsedDate != null) {
    final local = parsedDate.isUtc ? parsedDate.toLocal() : parsedDate;
    return local.hour * 3600 + local.minute * 60 + local.second;
  }

  final parts = value.split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  final second = parts.length > 2 ? int.tryParse(parts[2]) : 0;
  if (hour == null ||
      minute == null ||
      second == null ||
      hour < 0 ||
      hour > 23 ||
      minute < 0 ||
      minute > 59 ||
      second < 0 ||
      second > 59) {
    return null;
  }
  return hour * 3600 + minute * 60 + second;
}

class _WeatherAtTime {
  const _WeatherAtTime(this.snapshot, this.secondsOfDay);

  final WeatherSnapshot snapshot;
  final int secondsOfDay;
}

int _min(int left, int right) => left < right ? left : right;

int _max(int left, int right) => left > right ? left : right;

String _formatClock(int seconds) {
  const secondsPerDay = 24 * 60 * 60;
  final normalized = seconds % secondsPerDay;
  final hour = normalized ~/ 3600;
  final minute = normalized % 3600 ~/ 60;
  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
