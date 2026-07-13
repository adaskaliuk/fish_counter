import 'package:fish_counter/constants.dart';
import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/activity_log.dart';
import 'package:fish_counter/models/analytics_report.dart';
import 'package:fish_counter/models/fishing_window_forecast_report.dart';
import 'package:fish_counter/models/historical_catch_tuning_report.dart';
import 'package:fish_counter/models/weather_snapshot.dart';
import 'package:flutter/material.dart';

class AnalyticsDashboardSection extends StatelessWidget {
  const AnalyticsDashboardSection({
    super.key,
    required this.session,
    required this.report,
    required this.activityLogs,
    required this.l10n,
    required this.isCoach,
    this.tuning,
  });

  final GameSession session;
  final AnalyticsReport report;
  final List<ActivityLog> activityLogs;
  final AppLocalizations l10n;
  final bool isCoach;
  final HistoricalCatchTuningReport? tuning;

  @override
  Widget build(BuildContext context) {
    final forecast = FishingWindowForecastReport.fromSession(
      session,
      report,
      tuning: tuning,
    );
    final bestDay = forecast.bestDay;
    final contextLine = [
      if (session.weatherDescription.isNotEmpty) session.weatherDescription,
      if (session.astronomySummary.isNotEmpty) session.astronomySummary,
    ].join(' • ');
    final phaseCards = _buildPhaseCards();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCoach) ...[
          Text(
            l10n.dashboardTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 10),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${l10n.date}: ${session.date} • ${l10n.duration}: ${session.matchDuration}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .55),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _miniStat('C1', session.c1, Colors.white70),
                  _miniStat('TOTAL', session.total, Colors.orange),
                  _miniStat('C2', session.c2, Colors.white70),
                ],
              ),
              if (session.finalWeightKg != null || session.finalCount != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    if (session.finalWeightKg != null)
                      _metricTile('Final weight', '${session.finalWeightKg!.toStringAsFixed(2)} kg', Colors.lightBlueAccent),
                    if (session.finalCount != null)
                      _metricTile('Final count', session.finalCount.toString(), Colors.lightGreenAccent),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _avgMetric(
                      l10n.avgVibe,
                      '${report.averageInterval.toStringAsFixed(1)}s',
                      Colors.white,
                    ),
                  ),
                  Container(width: 1, height: 30, color: Colors.white24),
                  Expanded(
                    child: _avgMetric(
                      l10n.deviation,
                      '${report.averageDeviation > 0 ? '+' : ''}${report.averageDeviation.toStringAsFixed(2)}s',
                      report.averageDeviation.abs() < 1.5
                          ? Colors.green
                          : report.averageDeviation.abs() < 4
                          ? Colors.orange
                          : Colors.red,
                    ),
                  ),
                ],
              ),
              if (isCoach) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _metricTile(
                      l10n.readinessScore,
                      '${forecast.baseScore}%',
                      Colors.orange,
                    ),
                    _metricTile(l10n.bestWindow, bestDay.windowLabel(), Colors.green),
                    _metricTile(l10n.bestDay, bestDay.dayLabel(), Colors.lightBlueAccent),
                  ],
                ),
                if (phaseCards.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    l10n.phaseSplit,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: phaseCards
                        .map((phase) => SizedBox(width: 190, child: _phaseCard(phase)))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  l10n.forecast7Days,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: forecast.days
                        .map((day) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _forecastPill(
                                day.dayLabel(),
                                day.windowLabel(),
                                '${day.score}%',
                                highlighted: day == bestDay,
                              ),
                            ))
                        .toList(),
                  ),
                ),
                if (contextLine.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    contextLine,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .72),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricTile(String label, String value, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 2),
        Text(
          value.toString(),
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _avgMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _forecastPill(
    String day,
    String window,
    String score, {
    required bool highlighted,
  }) {
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: highlighted ? Colors.white12 : Colors.black12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted
              ? Colors.orange.withValues(alpha: .35)
              : Colors.white.withValues(alpha: .05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: TextStyle(
              color: highlighted ? Colors.orangeAccent : Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            window,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(
            score,
            style: TextStyle(
              color: highlighted ? Colors.greenAccent : Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  List<_PhaseSlice> _buildPhaseCards() {
    final logs = activityLogs
        .where((log) => log.type != ActivityType.manualPause)
        .toList(growable: false);
    if (logs.isEmpty) return const [];

    final phases = <_PhaseSlice>[];
    final baseSize = logs.length ~/ 3;
    final remainder = logs.length % 3;
    var cursor = 0;
    for (var index = 0; index < 3; index++) {
      final size = baseSize + (index < remainder ? 1 : 0);
      final start = cursor;
      final end = (cursor + size).clamp(0, logs.length);
      cursor = end;
      if (size == 0 || start >= logs.length) {
        phases.add(_PhaseSlice.empty(index + 1));
        continue;
      }
      final sliceLogs = logs.sublist(start, end);
      phases.add(
        _PhaseSlice.fromLogs(
          index + 1,
          sliceLogs,
          _weatherForPhase(index),
        ),
      );
    }
    return phases;
  }

  WeatherSnapshot? _weatherForPhase(int phaseIndex) {
    final snapshots = _weatherHistory();
    if (snapshots.isEmpty) return null;
    if (snapshots.length == 1) return snapshots.first;
    final target = ((phaseIndex / 2) * (snapshots.length - 1)).round();
    return snapshots[target.clamp(0, snapshots.length - 1)];
  }

  List<WeatherSnapshot> _weatherHistory() {
    if (session.weatherSnapshots.isNotEmpty) return session.weatherSnapshots;
    if (session.weatherPlace.isEmpty &&
        session.weatherDescription.isEmpty &&
        session.weatherFetchedAt.isEmpty &&
        session.weatherTemperatureCelsius == null &&
        session.weatherFeelsLikeCelsius == null &&
        session.weatherPressureHpa == null &&
        session.weatherHumidityPercent == null &&
        session.weatherWindSpeedMs == null &&
        session.weatherWindDirectionDegrees == null) {
      return const [];
    }
    return [
      WeatherSnapshot(
        latitude: session.latitude ?? 0,
        longitude: session.longitude ?? 0,
        placeName: session.weatherPlace,
        description: session.weatherDescription,
        temperatureCelsius: session.weatherTemperatureCelsius,
        feelsLikeCelsius: session.weatherFeelsLikeCelsius,
        pressureHpa: session.weatherPressureHpa,
        humidityPercent: session.weatherHumidityPercent,
        windSpeedMs: session.weatherWindSpeedMs,
        windDirectionDegrees: session.weatherWindDirectionDegrees,
        fetchedAt: session.weatherFetchedAt,
      ),
    ];
  }

  Widget _phaseCard(_PhaseSlice phase) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: .06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                phase.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                phase.count.toString(),
                style: const TextStyle(
                  color: Colors.lightGreenAccent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            phase.weatherLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .8),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            phase.avgIntervalLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _miniPhaseDot('G', Colors.greenAccent, phase.greenCount),
              _miniPhaseDot('O', Colors.orangeAccent, phase.orangeCount),
              _miniPhaseDot('R', Colors.redAccent, phase.redCount),
              _miniPhaseDot('E', Colors.blueAccent, phase.greyCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniPhaseDot(String label, Color color, int value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            '$label$value',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _PhaseSlice {
  final String label;
  final int count;
  final int greenCount;
  final int orangeCount;
  final int redCount;
  final int greyCount;
  final String avgIntervalLabel;
  final String weatherLabel;

  const _PhaseSlice({
    required this.label,
    required this.count,
    required this.greenCount,
    required this.orangeCount,
    required this.redCount,
    required this.greyCount,
    required this.avgIntervalLabel,
    required this.weatherLabel,
  });

  factory _PhaseSlice.fromLogs(
    int index,
    List<ActivityLog> logs,
    WeatherSnapshot? weather,
  ) {
    var green = 0;
    var orange = 0;
    var red = 0;
    var grey = 0;
    var total = 0.0;
    for (final log in logs) {
      total += log.interval.inSeconds;
      switch (log.status) {
        case Status.perfect:
        case Status.good:
          green++;
          break;
        case Status.average:
          orange++;
          break;
        case Status.poor:
          red++;
          break;
        case Status.early:
          grey++;
          break;
        case Status.pause:
          break;
      }
    }
    final avg = logs.isEmpty ? '--' : '${(total / logs.length).toStringAsFixed(1)}s';
    final weatherLabel = weather == null
        ? '--'
        : [
            if (weather.placeName.isNotEmpty) weather.placeName,
            if (weather.description.isNotEmpty) weather.description,
            if (weather.temperatureCelsius != null) '${weather.temperatureCelsius!.toStringAsFixed(1)}°C',
          ].join(' • ');
    return _PhaseSlice(
      label: '$index/3',
      count: logs.length,
      greenCount: green,
      orangeCount: orange,
      redCount: red,
      greyCount: grey,
      avgIntervalLabel: avg,
      weatherLabel: weatherLabel,
    );
  }

  factory _PhaseSlice.empty(int index) => _PhaseSlice(
        label: '$index/3',
        count: 0,
        greenCount: 0,
        orangeCount: 0,
        redCount: 0,
        greyCount: 0,
        avgIntervalLabel: '--',
        weatherLabel: '--',
      );
}
