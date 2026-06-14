import 'package:fish_counter/constants.dart';
import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/models/analytics_report.dart';

class ReportExporter {
  static String buildCsv(GameSession session) {
    final report = AnalyticsReport.fromGrid(session.grid);
    final rows = <List<String>>[
      ['section', 'key', 'value'],
      ['session', 'name', session.name],
      ['session', 'date', session.date],
      ['session', 'duration', session.matchDuration],
      ['counters', 'c1', session.c1.toString()],
      ['counters', 'c2', session.c2.toString()],
      ['counters', 'total', session.total.toString()],
      ['counters', 'tries', session.tries.toString()],
      ['context', 'athlete', session.athleteName],
      ['context', 'coach', session.coachName],
      ['context', 'venue', session.venue],
      ['context', 'sector_peg', session.sectorPeg],
      ['context', 'training_type', session.trainingType],
      ['context', 'fishing_method', session.fishingMethod],
      ['context', 'target_pace', session.targetPace],
      ['goals', 'fish_count', session.goalFishCount.toString()],
      [
        'goals',
        'target_pace_seconds',
        session.goalTargetPaceSeconds.toString(),
      ],
      ['goals', 'max_tries', session.goalMaxTries.toString()],
      ['goals', 'stability_percent', session.goalStabilityPercent.toString()],
      ['context', 'conditions', session.conditions],
      ['context', 'bait_notes', session.baitNotes],
      ['weather', 'place', session.weatherPlace],
      ['weather', 'description', session.weatherDescription],
      [
        'weather',
        'temperature_celsius',
        _num(session.weatherTemperatureCelsius),
      ],
      ['weather', 'feels_like_celsius', _num(session.weatherFeelsLikeCelsius)],
      ['weather', 'pressure_hpa', _num(session.weatherPressureHpa)],
      ['weather', 'humidity_percent', _num(session.weatherHumidityPercent)],
      ['weather', 'wind_speed_ms', _num(session.weatherWindSpeedMs)],
      [
        'weather',
        'wind_direction_degrees',
        _num(session.weatherWindDirectionDegrees),
      ],
      ['weather', 'latitude', _num(session.latitude)],
      ['weather', 'longitude', _num(session.longitude)],
      ['weather', 'fetched_at', session.weatherFetchedAt],
      ['analytics', 'stability_score', report.stabilityScore.toString()],
      [
        'analytics',
        'average_interval',
        report.averageInterval.toStringAsFixed(1),
      ],
      [
        'analytics',
        'average_deviation',
        report.averageDeviation.toStringAsFixed(2),
      ],
      [
        'analytics',
        'best_interval',
        report.bestIntervalSeconds?.toString() ?? '',
      ],
      [
        'analytics',
        'worst_interval',
        report.worstIntervalSeconds?.toString() ?? '',
      ],
      ['analytics', 'green', report.greenCount.toString()],
      ['analytics', 'orange', report.orangeCount.toString()],
      ['analytics', 'red', report.redCount.toString()],
      ['analytics', 'grey', report.greyCount.toString()],
      ['analytics', 'early', report.earlyCount.toString()],
      ['analytics', 'late', report.lateCount.toString()],
      ['analytics', 'best_streak', report.longestStableStreak.toString()],
      ['notes', 'athlete_note', session.athleteNote],
      ['notes', 'coach_comment', session.coachComment],
      [],
      ['timeline_timestamp', 'type', 'interval_seconds', 'status'],
      ...session.grid.map(
        (entry) => [
          entry['timestamp']?.toString() ?? '',
          _typeLabel(_toInt(entry['type'])),
          _toInt(entry['type']) == ActivityType.manualPause.value
              ? ''
              : _toInt(entry['interval']).toString(),
          entry['status']?.toString() ?? '',
        ],
      ),
    ];

    return rows.map(_csvRow).join('\n');
  }

  static String buildPlainText(GameSession session) {
    final report = AnalyticsReport.fromGrid(session.grid);
    final buffer = StringBuffer()
      ..writeln('FishCounter Training Report')
      ..writeln('===========================')
      ..writeln('Session: ${session.name}')
      ..writeln('Date: ${session.date}')
      ..writeln('Duration: ${session.matchDuration}')
      ..writeln()
      ..writeln('Counters')
      ..writeln('--------')
      ..writeln('C1: ${session.c1}')
      ..writeln('C2: ${session.c2}')
      ..writeln('Total: ${session.total}')
      ..writeln('Tries: ${session.tries}');

    _writeSection(buffer, 'Training Context', {
      'Athlete': session.athleteName,
      'Coach': session.coachName,
      'Venue': session.venue,
      'Sector / peg': session.sectorPeg,
      'Training type': session.trainingType,
      'Fishing method': session.fishingMethod,
      'Target pace': session.targetPace,
      'Conditions': session.conditions,
      'Bait / method notes': session.baitNotes,
    });

    _writeSection(buffer, 'Training Goals', {
      'Fish count': _positive(session.goalFishCount),
      'Target pace': _positive(session.goalTargetPaceSeconds, suffix: 's'),
      'Max tries': _positive(session.goalMaxTries),
      'Stability target': _positive(session.goalStabilityPercent, suffix: '%'),
    });

    _writeSection(buffer, 'Weather', {
      'Place': session.weatherPlace,
      'Description': session.weatherDescription,
      'Temperature': _unit(session.weatherTemperatureCelsius, '°C'),
      'Feels like': _unit(session.weatherFeelsLikeCelsius, '°C'),
      'Pressure': _unit(session.weatherPressureHpa, ' hPa'),
      'Humidity': _unit(session.weatherHumidityPercent, '%'),
      'Wind speed': _unit(session.weatherWindSpeedMs, ' m/s'),
      'Wind direction': _unit(session.weatherWindDirectionDegrees, '°'),
      'Fetched at': session.weatherFetchedAt,
    });

    buffer
      ..writeln()
      ..writeln('Coach Analytics')
      ..writeln('---------------')
      ..writeln('Stability score: ${report.stabilityScore}%')
      ..writeln(
        'Average interval: ${report.averageInterval.toStringAsFixed(1)}s',
      )
      ..writeln('Average deviation: ${_signed(report.averageDeviation)}s')
      ..writeln('Best interval: ${_interval(report.bestIntervalSeconds)}')
      ..writeln('Worst interval: ${_interval(report.worstIntervalSeconds)}')
      ..writeln('Green: ${report.greenCount}')
      ..writeln('Orange: ${report.orangeCount}')
      ..writeln('Red: ${report.redCount}')
      ..writeln('Grey: ${report.greyCount}')
      ..writeln('Early: ${report.earlyCount}')
      ..writeln('Late: ${report.lateCount}')
      ..writeln('Best stable streak: ${report.longestStableStreak}');

    _writeSection(buffer, 'Notes', {
      'Athlete note': session.athleteNote,
      'Coach comment': session.coachComment,
    });

    if (session.grid.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Timeline')
        ..writeln('--------');
      for (final entry in session.grid) {
        buffer.writeln(_timelineLine(entry));
      }
    }

    return buffer.toString().trimRight();
  }

  static void _writeSection(
    StringBuffer buffer,
    String title,
    Map<String, String> values,
  ) {
    final present = values.entries.where(
      (entry) => entry.value.trim().isNotEmpty,
    );
    if (present.isEmpty) return;

    buffer
      ..writeln()
      ..writeln(title)
      ..writeln('-' * title.length);
    for (final entry in present) {
      buffer.writeln('${entry.key}: ${entry.value.trim()}');
    }
  }

  static String _timelineLine(Map<String, dynamic> entry) {
    final timestamp = entry['timestamp']?.toString() ?? '--:--:--';
    final type = ActivityType.fromValue(_toInt(entry['type']));
    final label = _typeLabel(type.value);
    final interval = type == ActivityType.manualPause
        ? '-'
        : '${_toInt(entry['interval'])}s';
    final status = entry['status']?.toString() ?? '-';
    return '$timestamp | $label | $interval | $status';
  }

  static String _typeLabel(int value) {
    final type = ActivityType.fromValue(value);
    return switch (type) {
      ActivityType.c1Click => 'C1',
      ActivityType.c2Click => 'C2',
      ActivityType.tryClick => 'Try',
      ActivityType.manualPause => 'Pause',
      ActivityType.unknown => 'Unknown',
    };
  }

  static String _csvRow(List<String> values) => values.map(_csvValue).join(',');

  static String _csvValue(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  static String _num(double? value) => value?.toStringAsFixed(2) ?? '';

  static String _positive(int value, {String suffix = ''}) =>
      value > 0 ? '$value$suffix' : '';

  static String _unit(double? value, String unit) =>
      value == null ? '' : '${value.toStringAsFixed(1)}$unit';

  static String _interval(int? seconds) =>
      seconds == null ? '--' : '${seconds}s';

  static String _signed(double value) =>
      '${value > 0 ? '+' : ''}${value.toStringAsFixed(2)}';

  static int _toInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? defaultValue;
  }
}
