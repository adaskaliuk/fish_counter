import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/analytics_report.dart';
import 'package:fish_counter/models/fishing_window_forecast_report.dart';
import 'package:fish_counter/models/historical_catch_tuning_report.dart';
import 'package:flutter/material.dart';

class AnalyticsDashboardSection extends StatelessWidget {
  const AnalyticsDashboardSection({
    super.key,
    required this.session,
    required this.report,
    required this.l10n,
    this.tuning,
  });

  final GameSession session;
  final AnalyticsReport report;
  final AppLocalizations l10n;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dashboardTitle,
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
}
