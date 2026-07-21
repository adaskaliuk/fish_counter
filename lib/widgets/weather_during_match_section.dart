import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/match_insight_summary.dart';
import 'package:fish_counter/models/weather_snapshot.dart';
import 'package:flutter/material.dart';

class WeatherDuringMatchSection extends StatelessWidget {
  const WeatherDuringMatchSection({
    super.key,
    required this.session,
    required this.l10n,
  });

  final GameSession session;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final snapshots = _snapshots();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weather during match',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
        ),
        const SizedBox(height: 10),
        _fishermanSummary(snapshots),
        const SizedBox(height: 8),
        if (snapshots.isEmpty)
          Text(
            'No weather data for this match',
            style: TextStyle(color: Colors.grey.shade600),
          )
        else ...[
          if (snapshots.length > 1) _trend(snapshots),
          const SizedBox(height: 8),
          ...snapshots.map(_snapshotCard),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  List<WeatherSnapshot> _snapshots() {
    if (session.weatherSnapshots.isNotEmpty) return session.weatherSnapshots;
    final hasSessionWeather =
        session.weatherDescription.isNotEmpty ||
        session.weatherTemperatureCelsius != null ||
        session.weatherPressureHpa != null ||
        session.weatherHumidityPercent != null ||
        session.weatherWindSpeedMs != null;
    if (!hasSessionWeather) return const [];
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

  Widget _fishermanSummary(List<WeatherSnapshot> snapshots) {
    final insight = MatchInsightSummary.fromSession(
      session,
      snapshots: snapshots,
    );
    if (insight == null) {
      return const Text(
        'No activity events recorded for match insight.',
        style: TextStyle(color: Colors.white70, fontSize: 12),
      );
    }

    final best = insight.bestWindow;
    final buffer = StringBuffer(
      'Match insight: highest activity window ${best.label} '
      '(${best.eventCount} ${best.eventCount == 1 ? 'event' : 'events'}).',
    );
    final quietest = insight.quietestWindow;
    if (quietest.startSeconds != best.startSeconds) {
      buffer.write(
        ' Quietest window ${quietest.label} '
        '(${quietest.eventCount} ${quietest.eventCount == 1 ? 'event' : 'events'}).',
      );
    }

    final weather = insight.nearestWeather;
    if (weather != null) {
      final details = <String>[
        if (weather.description.isNotEmpty) weather.description,
        if (weather.temperatureCelsius != null)
          '${weather.temperatureCelsius!.toStringAsFixed(1)}°C',
        if (weather.description.isEmpty &&
            weather.temperatureCelsius == null &&
            weather.placeName.isNotEmpty)
          weather.placeName,
      ];
      if (details.isNotEmpty) {
        buffer.write(' Nearby weather: ${details.join(', ')}');
        if (insight.nearestWeatherTimeLabel.isNotEmpty) {
          buffer.write(' at ${insight.nearestWeatherTimeLabel}');
        }
        buffer.write('.');
      }
    }

    return Text(
      buffer.toString(),
      style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.35),
    );
  }

  Widget _trend(List<WeatherSnapshot> snapshots) {
    final first = snapshots.first;
    final last = snapshots.last;
    final parts = <String>[];
    final temp = _delta(
      first.temperatureCelsius,
      last.temperatureCelsius,
      'temp',
    );
    if (temp.isNotEmpty) parts.add(temp);
    final pressure = _delta(first.pressureHpa, last.pressureHpa, 'pressure');
    if (pressure.isNotEmpty) parts.add(pressure);
    final winds = snapshots
        .map((s) => s.windSpeedMs)
        .whereType<double>()
        .toList();
    if (winds.isNotEmpty) {
      winds.sort();
      parts.add('max wind ${winds.last.toStringAsFixed(1)} m/s');
    }
    if (parts.isEmpty) return const SizedBox.shrink();
    return Text(
      parts.join(' • '),
      style: const TextStyle(color: Colors.white70, fontSize: 12),
    );
  }

  String _delta(double? from, double? to, String label) {
    if (from == null || to == null) return '';
    final diff = to - from;
    if (diff.abs() < 0.1) return '$label stable';
    final arrow = diff > 0 ? 'up' : 'down';
    return '$label $arrow ${diff.abs().toStringAsFixed(1)}';
  }

  Widget _snapshotCard(WeatherSnapshot snapshot) {
    final rows = <String>[
      if (snapshot.fetchedAt.isNotEmpty) snapshot.fetchedAt,
      if (snapshot.description.isNotEmpty) snapshot.description,
      if (snapshot.temperatureCelsius != null)
        '${l10n.temperatureLabel}: ${snapshot.temperatureCelsius!.toStringAsFixed(1)}°C',
      if (snapshot.pressureHpa != null)
        '${l10n.pressureLabel}: ${snapshot.pressureHpa!.toStringAsFixed(0)} hPa',
      if (snapshot.humidityPercent != null)
        '${l10n.humidityLabel}: ${snapshot.humidityPercent!.toStringAsFixed(0)}%',
      if (snapshot.windSpeedMs != null)
        '${l10n.windSpeedLabel}: ${snapshot.windSpeedMs!.toStringAsFixed(1)} m/s',
      if (snapshot.windDirectionDegrees != null)
        '${l10n.windDirectionLabel}: ${snapshot.windDirectionDegrees!.toStringAsFixed(0)}°',
    ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        rows.join('\n'),
        style: const TextStyle(color: Colors.white70, height: 1.35),
      ),
    );
  }
}
