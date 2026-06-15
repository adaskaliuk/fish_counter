import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/analytics_report.dart';
import 'package:fish_counter/models/progress_report.dart';
import 'package:fish_counter/models/weather_correlation_report.dart';
import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, required this.sessions});

  final List<GameSession> sessions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final report = ProgressReport(sessions);
    final weather = WeatherCorrelationReport(sessions);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.progressTrends)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _heroCard(l10n, report),
          const SizedBox(height: 18),
          _sectionCard(
            title: l10n.personalRecords,
            children: [
              _recordTile(
                l10n.bestFishCount,
                report.bestFishCountSession,
                (session) => '${session.total}',
              ),
              _recordTile(
                l10n.bestStability,
                report.bestStabilitySession,
                (session) =>
                    '${AnalyticsReport.fromGrid(session.grid).stabilityScore}%',
              ),
              _recordTile(
                l10n.fewestTries,
                report.fewestTriesSession,
                (session) => '${session.tries}',
              ),
            ],
          ),
          const SizedBox(height: 18),
          _sectionCard(
            title: l10n.recentTrend,
            children: report.hasEnoughForTrend
                ? [
                    _trendTile(
                      context,
                      l10n.averageFish,
                      report.averageFishCount.toStringAsFixed(1),
                      report.totalFishDelta,
                      report.fishTrend,
                    ),
                    _trendTile(
                      context,
                      l10n.averageStability,
                      '${report.averageStability.toStringAsFixed(1)}%',
                      report.stabilityDelta,
                      report.stabilityTrend,
                      suffix: '%',
                    ),
                  ]
                : [Text(l10n.notEnoughSessions)],
          ),
          const SizedBox(height: 18),
          _sectionCard(
            title: l10n.weatherCorrelation,
            children: weather.hasEnoughData
                ? [
                    _weatherTile(
                      l10n.weatherSessions,
                      '${weather.sampleSize}',
                      '${weather.averageTemperature.toStringAsFixed(1)}°C • ${weather.averageWind.toStringAsFixed(1)} m/s',
                    ),
                    _weatherTile(
                      l10n.bestWeatherSession,
                      weather.bestWeatherSession?.name ?? '-',
                      weather.bestWeatherSession?.weatherDescription ?? '-',
                    ),
                    _signalTile(
                      context,
                      l10n.temperatureSignal,
                      weather.stabilityTemperatureCorrelation,
                      weather.temperatureSignal,
                    ),
                    _signalTile(
                      context,
                      l10n.windSignal,
                      weather.totalWindCorrelation,
                      weather.windSignal,
                    ),
                  ]
                : [Text(l10n.notEnoughWeatherData)],
          ),
        ],
      ),
    );
  }

  Widget _heroCard(AppLocalizations l10n, ProgressReport report) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.withValues(alpha: .32), Colors.white10],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.progressTrends,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${report.sessionsAnalyzed}',
              style: const TextStyle(
                color: Colors.orangeAccent,
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _recordTile(
    String title,
    GameSession? session,
    String Function(GameSession session) value,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(session?.name ?? '-'),
      trailing: Text(
        session == null ? '-' : value(session),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _trendTile(
    BuildContext context,
    String title,
    String average,
    int delta,
    ProgressTrend trend, {
    String suffix = '',
  }) {
    final l10n = AppLocalizations.of(context);
    final (label, color, icon) = switch (trend) {
      ProgressTrend.improving => (
        l10n.improving,
        Colors.green,
        Icons.trending_up,
      ),
      ProgressTrend.declining => (
        l10n.declining,
        Colors.red,
        Icons.trending_down,
      ),
      ProgressTrend.stable => (l10n.stable, Colors.grey, Icons.trending_flat),
    };
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text('${l10n.average}: $average • $label'),
      trailing: Text('${delta >= 0 ? '+' : ''}$delta$suffix'),
    );
  }

  Widget _weatherTile(String title, String value, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.cloud_outlined, color: Colors.lightBlueAccent),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(
        value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _signalTile(
    BuildContext context,
    String title,
    double value,
    WeatherSignal signal,
  ) {
    final l10n = AppLocalizations.of(context);
    final (label, color, icon) = switch (signal) {
      WeatherSignal.positive => (
        l10n.improving,
        Colors.green,
        Icons.trending_up,
      ),
      WeatherSignal.negative => (
        l10n.declining,
        Colors.red,
        Icons.trending_down,
      ),
      WeatherSignal.neutral => (l10n.stable, Colors.grey, Icons.trending_flat),
    };
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(label),
      trailing: Text(value.toStringAsFixed(2)),
    );
  }
}
