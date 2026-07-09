import 'package:fish_counter/constants.dart';
import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/analytics_report.dart';
import 'package:fish_counter/models/fishing_window_forecast_report.dart';
import 'package:fish_counter/models/historical_catch_tuning_report.dart';

class ReportExporter {
  static String buildCsv(
    GameSession session, {
    AppLocalizations? l10n,
    HistoricalCatchTuningReport? tuning,
    bool isCoach = false,
  }) {
    final report = AnalyticsReport.fromGrid(session.grid);
    final forecast = FishingWindowForecastReport.fromSession(
      session,
      report,
      tuning: tuning,
    );
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
      if (isCoach && session.coachName.isNotEmpty)
        ['context', 'coach', session.coachName],
      ['context', 'venue', session.venueInfo.venue],
      ['context', 'sector_peg', session.venueInfo.sectorPeg],
      ['context', 'training_type', session.venueInfo.trainingType],
      ['context', 'fishing_method', session.venueInfo.fishingMethod],
      ['context', 'target_pace', session.venueInfo.targetPace],
      ['goals', 'fish_count', session.goals.goalFishCount.toString()],
      [
        'goals',
        'target_pace_seconds',
        session.goals.goalTargetPaceSeconds.toString(),
      ],
      ['goals', 'max_tries', session.goals.goalMaxTries.toString()],
      [
        'goals',
        'stability_percent',
        session.goals.goalStabilityPercent.toString(),
      ],
      ['context', 'conditions', session.venueInfo.conditions],
      ['context', 'bait_notes', session.venueInfo.baitNotes],
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
      ['forecast', 'readiness_score', '${forecast.baseScore}%'],
      ['forecast', 'best_window', forecast.bestDay.windowLabel()],
      [
        'forecast',
        'best_day',
        forecast.bestDay.dayLabel(l10n?.locale.languageCode),
      ],
      ['forecast', 'best_day_score', '${forecast.bestDay.score}%'],
      if (tuning != null && !tuning.isEmpty) ...[
        ['history_tuning', 'sessions_analyzed', tuning.sessionCount.toString()],
        [
          'history_tuning',
          'fish_count_weight',
          tuning.fishCountWeight.toStringAsFixed(2),
        ],
        [
          'history_tuning',
          'stability_weight',
          tuning.stabilityWeight.toStringAsFixed(2),
        ],
        [
          'history_tuning',
          'tries_weight',
          tuning.triesWeight.toStringAsFixed(2),
        ],
        ['history_tuning', 'pace_weight', tuning.paceWeight.toStringAsFixed(2)],
      ],
      ['notes', 'athlete_note', session.athleteNote],
      if (isCoach) ['notes', 'coach_comment', session.coachComment],
      [],
      ['timeline_timestamp', 'type', 'interval_seconds', 'status'],
      ...session.grid.map(
        (entry) => [
          entry['timestamp']?.toString() ?? '',
          _typeLabel(_toInt(entry['type']), l10n: l10n),
          _toInt(entry['type']) == ActivityType.manualPause.value
              ? ''
              : _toInt(entry['interval']).toString(),
          entry['status']?.toString() ?? '',
        ],
      ),
    ];

    return rows.map(_csvRow).join('\n');
  }

  static String buildPlainText(
    GameSession session, {
    AppLocalizations? l10n,
    HistoricalCatchTuningReport? tuning,
    bool isCoach = false,
  }) {
    final report = AnalyticsReport.fromGrid(session.grid);
    final forecast = FishingWindowForecastReport.fromSession(
      session,
      report,
      tuning: tuning,
    );
    final buffer = StringBuffer()
      ..writeln((l10n?.precisionReport ?? 'FishCounter Training Report'))
      ..writeln('===========================')
      ..writeln('${(l10n?.sessionName ?? 'Session')}: ${session.name}')
      ..writeln('${(l10n?.date ?? 'Date')}: ${session.date}')
      ..writeln('${(l10n?.duration ?? 'Duration')}: ${session.matchDuration}')
      ..writeln()
      ..writeln((l10n?.countersSection ?? 'Counters'))
      ..writeln('--------')
      ..writeln('C1: ${session.c1}')
      ..writeln('C2: ${session.c2}')
      ..writeln('C1+C2: ${session.total}')
      ..writeln('${(l10n?.tryCount ?? 'Tries')}: ${session.tries}');

    _writeSection(buffer, (l10n?.trainingContext ?? 'Training Context'), {
      (l10n?.athleteName ?? 'Athlete'): session.athleteName,
      if (isCoach) (l10n?.coachName ?? 'Coach'): session.coachName,
      (l10n?.venue ?? 'Venue'): session.venueInfo.venue,
      (l10n?.sectorPeg ?? 'Sector / peg'): session.venueInfo.sectorPeg,
      (l10n?.trainingType ?? 'Training type'): session.venueInfo.trainingType,
      (l10n?.fishingMethod ?? 'Fishing method'):
          session.venueInfo.fishingMethod,
      (l10n?.targetPace ?? 'Target pace'): session.venueInfo.targetPace,
      (l10n?.conditions ?? 'Conditions'): session.venueInfo.conditions,
      (l10n?.baitNotes ?? 'Bait / method notes'): session.venueInfo.baitNotes,
    });

    _writeSection(buffer, (l10n?.trainingGoals ?? 'Training Goals'), {
      (l10n?.fishCount ?? 'Fish count'): _positive(session.goals.goalFishCount),
      (l10n?.targetPace ?? 'Target pace'): _positive(
        session.goals.goalTargetPaceSeconds,
        suffix: 's',
      ),
      (l10n?.maxTries ?? 'Max tries'): _positive(session.goals.goalMaxTries),
      (l10n?.stabilityTarget ?? 'Stability target'): _positive(
        session.goalStabilityPercent,
        suffix: '%',
      ),
    });

    _writeSection(buffer, (l10n?.weatherSummary ?? 'Weather'), {
      (l10n?.placeLabel ?? 'Place'): session.weatherPlace,
      (l10n?.descriptionLabel ?? 'Description'): session.weatherDescription,
      (l10n?.temperatureLabel ?? 'Temperature'): _unit(
        session.weatherTemperatureCelsius,
        '°C',
      ),
      (l10n?.feelsLikeLabel ?? 'Feels like'): _unit(
        session.weatherFeelsLikeCelsius,
        '°C',
      ),
      (l10n?.pressureLabel ?? 'Pressure'): _unit(
        session.weatherPressureHpa,
        ' hPa',
      ),
      (l10n?.humidityLabel ?? 'Humidity'): _unit(
        session.weatherHumidityPercent,
        '%',
      ),
      (l10n?.windSpeedLabel ?? 'Wind speed'): _unit(
        session.weatherWindSpeedMs,
        ' m/s',
      ),
      (l10n?.windDirectionLabel ?? 'Wind direction'): _unit(
        session.weatherWindDirectionDegrees,
        '°',
      ),
      (l10n?.fetchedAtLabel ?? 'Fetched at'): session.weatherFetchedAt,
    });

    if (isCoach) {
      buffer
        ..writeln()
        ..writeln((l10n?.coachSummary ?? 'Coach Analytics'))
        ..writeln(
          '${(l10n?.stabilityScore ?? 'Stability score')}: ${report.stabilityScore}%',
        )
        ..writeln(
          '${l10n?.averageInterval ?? 'Average interval'}: ${report.averageInterval.toStringAsFixed(1)}s',
        )
        ..writeln(
          '${l10n?.averageDeviation ?? 'Average deviation'}: ${_signed(report.averageDeviation)}s',
        )
        ..writeln(
          '${l10n?.bestInterval ?? 'Best interval'}: ${_interval(report.bestIntervalSeconds)}',
        )
        ..writeln(
          '${l10n?.worstInterval ?? 'Worst interval'}: ${_interval(report.worstIntervalSeconds)}',
        )
        ..writeln('${l10n?.green ?? 'Green'}: ${report.greenCount}')
        ..writeln('${l10n?.orange ?? 'Orange'}: ${report.orangeCount}')
        ..writeln('${l10n?.red ?? 'Red'}: ${report.redCount}')
        ..writeln('${l10n?.grey ?? 'Grey'}: ${report.greyCount}')
        ..writeln('${l10n?.earlyCount ?? 'Early'}: ${report.earlyCount}')
        ..writeln('${l10n?.lateCount ?? 'Late'}: ${report.lateCount}')
        ..writeln(
          '${l10n?.longestStableStreak ?? 'Best stable streak'}: ${report.longestStableStreak}',
        );
    }

    _writeSection(buffer, (l10n?.bestWindowForecast ?? 'Forecast'), {
      (l10n?.readinessScore ?? 'Readiness score'): '${forecast.baseScore}%',
      (l10n?.bestWindow ?? 'Best window'): forecast.bestDay.windowLabel(),
      (l10n?.bestDay ?? 'Best day'): forecast.bestDay.dayLabel(
        l10n?.locale.languageCode,
      ),
      (l10n?.bestDayScore ?? 'Best day score'): '${forecast.bestDay.score}%',
    });

    if (tuning != null && !tuning.isEmpty) {
      final sessionsAnalyzedLabel =
          (l10n?.sessionsAnalyzed ?? 'Sessions analyzed');
      final fishCountLabel = (l10n?.fishCount ?? 'Fish count');
      final stabilityLabel = (l10n?.stabilityScore ?? 'Stability score');
      final maxTriesLabel = (l10n?.maxTries ?? 'Max tries');
      final avgPaceLabel = (l10n?.avgPace ?? 'Avg pace');
      _writeSection(buffer, (l10n?.historicalTuning ?? 'Historical tuning'), {
        sessionsAnalyzedLabel: tuning.sessionCount.toString(),
        fishCountLabel: tuning.fishCountWeight.toStringAsFixed(2),
        stabilityLabel: tuning.stabilityWeight.toStringAsFixed(2),
        maxTriesLabel: tuning.triesWeight.toStringAsFixed(2),
        avgPaceLabel: tuning.paceWeight.toStringAsFixed(2),
      });
    }

    _writeSection(buffer, l10n?.sessionNotes ?? 'Notes', {
      (l10n?.athleteNote ?? 'Athlete note'): session.athleteNote,
      if (isCoach)
        (l10n?.coachComment ?? 'Coach comment'): session.coachComment,
    });

    if (session.grid.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(l10n?.activityTimeline ?? 'Timeline')
        ..writeln('--------');
      for (final entry in session.grid) {
        buffer.writeln(_timelineLine(entry, l10n: l10n));
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

  static String _timelineLine(
    Map<String, dynamic> entry, {
    AppLocalizations? l10n,
  }) {
    final timestamp = entry['timestamp']?.toString() ?? '--:--:--';
    final type = ActivityType.fromValue(_toInt(entry['type']));
    final label = _typeLabel(type.value, l10n: l10n);
    final interval = type == ActivityType.manualPause
        ? '-'
        : '${_toInt(entry['interval'])}s';
    final status = entry['status']?.toString() ?? '-';
    return '$timestamp | $label | $interval | $status';
  }

  static String _typeLabel(int value, {AppLocalizations? l10n}) {
    final type = ActivityType.fromValue(value);
    return switch (type) {
      ActivityType.c1Click => l10n?.c1Click ?? 'C1',
      ActivityType.c2Click => l10n?.c2Click ?? 'C2',
      ActivityType.tryClick => l10n?.tryError ?? 'Try',
      ActivityType.manualPause => l10n?.pauseReset ?? 'Pause',
      ActivityType.unknown => l10n?.unknown ?? 'Unknown',
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
