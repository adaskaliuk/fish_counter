import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class HistorySessionDetails extends StatelessWidget {
  const HistorySessionDetails({
    super.key,
    required this.session,
    required this.l10n,
  });

  final GameSession session;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final hasWeather = session.weatherPlace.isNotEmpty ||
        session.weatherDescription.isNotEmpty ||
        session.weatherFetchedAt.isNotEmpty ||
        session.weatherTemperatureCelsius != null ||
        session.weatherFeelsLikeCelsius != null ||
        session.weatherPressureHpa != null ||
        session.weatherHumidityPercent != null ||
        session.weatherWindSpeedMs != null ||
        session.weatherWindDirectionDegrees != null ||
        session.astronomySummary.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _chip('C1', session.c1.toString()),
            _chip('C2', session.c2.toString()),
            _chip(l10n.tryButton.toUpperCase(), session.tries.toString()),
            _chip('TOTAL', session.total.toString()),
          ],
        ),
        if (hasWeather) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.weatherSummary,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                if (session.weatherPlace.isNotEmpty)
                  Text(
                    '${l10n.placeLabel}: ${session.weatherPlace}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                if (session.weatherDescription.isNotEmpty)
                  Text(
                    '${l10n.descriptionLabel}: ${session.weatherDescription}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    _kv(l10n.temperatureLabel, _temperature(session.weatherTemperatureCelsius)),
                    _kv(l10n.feelsLikeLabel, _temperature(session.weatherFeelsLikeCelsius)),
                    _kv(l10n.pressureLabel, _pressure(session.weatherPressureHpa)),
                    _kv(l10n.humidityLabel, _percentage(session.weatherHumidityPercent)),
                    _kv(l10n.windSpeedLabel, _windSpeed(session.weatherWindSpeedMs)),
                    _kv(l10n.windDirectionLabel, _windDirection(session.weatherWindDirectionDegrees)),
                  ],
                ),
                if (session.weatherFetchedAt.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.fetchedAtLabel}: ${session.weatherFetchedAt}',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
                if (session.astronomySummary.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.astronomyContext}: ${session.astronomySummary}',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _chip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        '$label $value',
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _kv(String label, String value) {
    return Text(
      '$label $value',
      style: const TextStyle(color: Colors.white70, fontSize: 12),
    );
  }

  String _temperature(double? value) => value == null ? '--' : '${value.toStringAsFixed(1)}°C';
  String _pressure(double? value) => value == null ? '--' : '${value.toStringAsFixed(0)} hPa';
  String _percentage(double? value) => value == null ? '--' : '${value.toStringAsFixed(0)}%';
  String _windSpeed(double? value) => value == null ? '--' : '${value.toStringAsFixed(1)} m/s';
  String _windDirection(double? value) => value == null ? '--' : '${value.toStringAsFixed(0)}°';
}
