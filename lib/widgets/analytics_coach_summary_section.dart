import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/analytics_report.dart';
import 'package:flutter/material.dart';

class AnalyticsCoachSummarySection extends StatelessWidget {
  const AnalyticsCoachSummarySection({
    super.key,
    required this.report,
    required this.l10n,
  });

  final AnalyticsReport report;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final best = report.bestIntervalSeconds == null
        ? '--'
        : '${report.bestIntervalSeconds}s';
    final worst = report.worstIntervalSeconds == null
        ? '--'
        : '${report.worstIntervalSeconds}s';

    return Column(
      children: [
        Row(
          children: [
            _metricTile(
              l10n.stabilityScore,
              '${report.stabilityScore}%',
              Colors.green,
            ),
            const SizedBox(width: 10),
            _metricTile(l10n.bestInterval, best, Colors.white),
            const SizedBox(width: 10),
            _metricTile(l10n.worstInterval, worst, Colors.white),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _metricTile(l10n.green, report.greenCount.toString(), Colors.green),
            const SizedBox(width: 10),
            _metricTile(
              l10n.orange,
              report.orangeCount.toString(),
              Colors.orange,
            ),
            const SizedBox(width: 10),
            _metricTile(l10n.red, report.redCount.toString(), Colors.red),
            const SizedBox(width: 10),
            _metricTile(l10n.grey, report.greyCount.toString(), Colors.grey),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _metricTile(
              l10n.tryCount,
              report.tryCount.toString(),
              Colors.white,
            ),
            const SizedBox(width: 10),
            _metricTile(
              l10n.earlyCount,
              report.earlyCount.toString(),
              Colors.grey,
            ),
            const SizedBox(width: 10),
            _metricTile(
              l10n.lateCount,
              report.lateCount.toString(),
              Colors.red,
            ),
            const SizedBox(width: 10),
            _metricTile(
              l10n.longestStableStreak,
              report.longestStableStreak.toString(),
              Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _metricTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
