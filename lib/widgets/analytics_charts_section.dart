import 'package:fish_counter/constants.dart';
import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/activity_log.dart';
import 'package:fish_counter/models/analytics_report.dart';
import 'package:fish_counter/widgets/activity_heatmap_card.dart';
import 'package:fish_counter/widgets/session_line_chart.dart';
import 'package:flutter/material.dart';

class AnalyticsChartsSection extends StatelessWidget {
  const AnalyticsChartsSection({
    super.key,
    required this.session,
    required this.report,
    required this.activityLogs,
    required this.l10n,
  });

  final GameSession session;
  final AnalyticsReport report;
  final List<ActivityLog> activityLogs;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_chartPoints.isNotEmpty) ...[
          const SizedBox(height: 32),
          _chartCard(
            title: l10n.paceChart,
            value: '${report.averageInterval.toStringAsFixed(1)}s',
            caption: l10n.avgPace,
            points: _chartPoints,
            accent: Colors.orangeAccent,
          ),
          const SizedBox(height: 16),
          _chartCard(
            title: l10n.activityChart,
            value: '${session.total}',
            caption: l10n.fishCount,
            points: _activityPoints,
            accent: Colors.lightGreenAccent,
          ),
        ],
        if (activityLogs.isNotEmpty) ...[
          const SizedBox(height: 16),
          ActivityHeatmapCard(logs: activityLogs, l10n: l10n),
        ],
      ],
    );
  }

  List<ChartPoint> get _chartPoints {
    final points = <ChartPoint>[];
    for (final log in activityLogs) {
      if (log.type == ActivityType.manualPause) continue;
      points.add(
        ChartPoint(points.length.toDouble(), log.interval.inSeconds.toDouble()),
      );
    }
    return points;
  }

  List<ChartPoint> get _activityPoints {
    final points = <ChartPoint>[];
    var count = 0;
    for (final log in activityLogs) {
      if (log.type == ActivityType.manualPause) continue;
      if (log.type == ActivityType.c1Click ||
          log.type == ActivityType.c2Click) {
        count++;
      }
      points.add(ChartPoint(points.length.toDouble(), count.toDouble()));
    }
    return points;
  }

  Widget _chartCard({
    required String title,
    required String value,
    required String caption,
    required List<ChartPoint> points,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: .16),
            Colors.white.withValues(alpha: .04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Container(
        height: 220,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: .08)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: .12),
              blurRadius: 34,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: accent,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.5,
                  ),
                ),
              ],
            ),
            Text(
              caption,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .38),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SessionLineChart(points: points, accent: accent),
            ),
          ],
        ),
      ),
    );
  }
}
