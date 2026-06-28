import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class AnalyticsWeatherSection extends StatelessWidget {
  const AnalyticsWeatherSection({
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

    if (!hasWeather) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.weatherSummary,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 10),
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
              if (session.weatherPlace.isNotEmpty)
                Text(
                  '${l10n.placeLabel}: ${session.weatherPlace}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              if (session.weatherDescription.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  '${l10n.descriptionLabel}: ${session.weatherDescription}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _metric(
                    l10n.temperatureLabel,
                    _temperature(session.weatherTemperatureCelsius),
                  ),
                  _metric(
                    l10n.feelsLikeLabel,
                    _temperature(session.weatherFeelsLikeCelsius),
                  ),
                  _metric(
                    l10n.pressureLabel,
                    _pressure(session.weatherPressureHpa),
                  ),
                  _metric(
                    l10n.humidityLabel,
                    _percentage(session.weatherHumidityPercent),
                  ),
                  _metric(
                    l10n.windSpeedLabel,
                    _windSpeed(session.weatherWindSpeedMs),
                  ),
                  _metric(
                    l10n.windDirectionLabel,
                    _windDirection(session.weatherWindDirectionDegrees),
                  ),
                ],
              ),
              if (session.weatherFetchedAt.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  '${l10n.fetchedAtLabel}: ${session.weatherFetchedAt}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .7),
                    fontSize: 12,
                  ),
                ),
              ],
              if (session.astronomySummary.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.astronomyContext,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session.astronomySummary,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .75),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _metric(String label, String value) {
    return Container(
      width: 128,
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  String _temperature(double? value) =>
      value == null ? '--' : '${value.toStringAsFixed(1)}°C';

  String _pressure(double? value) =>
      value == null ? '--' : '${value.toStringAsFixed(0)} hPa';

  String _percentage(double? value) =>
      value == null ? '--' : '${value.toStringAsFixed(0)}%';

  String _windSpeed(double? value) =>
      value == null ? '--' : '${value.toStringAsFixed(1)} m/s';

  String _windDirection(double? value) =>
      value == null ? '--' : '${value.toStringAsFixed(0)}°';
}
