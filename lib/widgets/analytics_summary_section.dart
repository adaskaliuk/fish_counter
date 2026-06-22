import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/analytics_report.dart';
import 'package:flutter/material.dart';

import 'analytics_coach_summary_section.dart';
import 'analytics_summary_stats.dart';

class AnalyticsSummarySection extends StatelessWidget {
  const AnalyticsSummarySection({
    super.key,
    required this.session,
    required this.report,
    required this.l10n,
  });

  final GameSession session;
  final AnalyticsReport report;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          session.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        Text(
          '${l10n.date}: ${session.date} | ${l10n.duration}: ${session.matchDuration}',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const Divider(height: 30),
        if (_hasTrainingContext) ...[
          Text(
            l10n.trainingContext,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 10),
          _buildTrainingContext(),
          const SizedBox(height: 25),
        ],
        AnalyticsSummaryStats(
          session: session,
          averageInterval: report.averageInterval,
          averageDeviation: report.averageDeviation,
          avgVibeLabel: l10n.avgVibe,
          deviationLabel: l10n.deviation,
        ),
        const SizedBox(height: 30),
        Text(
          l10n.coachSummary,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 10),
        AnalyticsCoachSummarySection(report: report, l10n: l10n),
      ],
    );
  }

  bool get _hasTrainingContext =>
      session.athleteName.isNotEmpty ||
      session.coachName.isNotEmpty ||
      session.venue.isNotEmpty ||
      session.sectorPeg.isNotEmpty ||
      session.trainingType.isNotEmpty ||
      session.fishingMethod.isNotEmpty ||
      session.targetPace.isNotEmpty ||
      session.conditions.isNotEmpty ||
      session.baitNotes.isNotEmpty ||
      session.weatherDescription.isNotEmpty;

  Widget _buildTrainingContext() {
    final rows = <Widget>[
      if (session.athleteName.isNotEmpty)
        _contextRow(l10n.athleteName, session.athleteName),
      if (session.coachName.isNotEmpty)
        _contextRow(l10n.coachName, session.coachName),
      if (session.venue.isNotEmpty) _contextRow(l10n.venue, session.venue),
      if (session.sectorPeg.isNotEmpty)
        _contextRow(l10n.sectorPeg, session.sectorPeg),
      if (session.trainingType.isNotEmpty)
        _contextRow(l10n.trainingType, session.trainingType),
      if (session.fishingMethod.isNotEmpty)
        _contextRow(l10n.fishingMethod, session.fishingMethod),
      if (session.targetPace.isNotEmpty)
        _contextRow(l10n.targetPace, session.targetPace),
      if (session.conditions.isNotEmpty)
        _contextRow(l10n.conditions, session.conditions),
      if (session.baitNotes.isNotEmpty)
        _contextRow(l10n.baitNotes, session.baitNotes),
      if (session.weatherDescription.isNotEmpty)
        _contextRow(l10n.weatherSummary, _weatherSummary),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: rows),
    );
  }

  String get _weatherSummary {
    final parts = <String>[];
    if (session.weatherPlace.isNotEmpty) parts.add(session.weatherPlace);
    if (session.weatherDescription.isNotEmpty) {
      parts.add(session.weatherDescription);
    }
    final temp = session.weatherTemperatureCelsius;
    if (temp != null) parts.add('${temp.toStringAsFixed(1)}°C');
    final wind = session.weatherWindSpeedMs;
    if (wind != null) parts.add('wind ${wind.toStringAsFixed(1)} m/s');
    final pressure = session.weatherPressureHpa;
    if (pressure != null) parts.add('${pressure.toStringAsFixed(0)} hPa');
    final humidity = session.weatherHumidityPercent;
    if (humidity != null) parts.add('${humidity.toStringAsFixed(0)}%');
    return parts.join(' • ');
  }

  Widget _contextRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
