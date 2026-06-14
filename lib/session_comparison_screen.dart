import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/session_comparison_report.dart';
import 'package:flutter/material.dart';

class SessionComparisonScreen extends StatelessWidget {
  const SessionComparisonScreen({
    super.key,
    required this.base,
    required this.compare,
  });

  final GameSession base;
  final GameSession compare;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final report = SessionComparisonReport(base: base, compare: compare);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.compareSessions)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _heroCard('${base.name} → ${compare.name}'),
          const SizedBox(height: 18),
          _metricCard(
            children: [
              _metric(
                l10n.fishCount,
                base.total,
                compare.total,
                report.totalDelta,
              ),
              _metric('C1', base.c1, compare.c1, report.c1Delta),
              _metric('C2', base.c2, compare.c2, report.c2Delta),
              _metric(
                l10n.tryCount,
                base.tries,
                compare.tries,
                report.triesDelta,
              ),
              _metric(
                l10n.stabilityScore,
                report.baseAnalytics.stabilityScore,
                report.compareAnalytics.stabilityScore,
                report.stabilityDelta,
                suffix: '%',
              ),
              _metricDouble(
                l10n.avgPace,
                report.baseAnalytics.averageInterval,
                report.compareAnalytics.averageInterval,
                report.averageIntervalDelta,
                suffix: 's',
                lowerIsBetter: true,
              ),
              _metricDouble(
                l10n.deviation,
                report.baseAnalytics.averageDeviation,
                report.compareAnalytics.averageDeviation,
                report.averageDeviationDelta,
                suffix: 's',
                lowerIsBetter: true,
              ),
              _metric(
                l10n.longestStableStreak,
                report.baseAnalytics.longestStableStreak,
                report.compareAnalytics.longestStableStreak,
                report.longestStableStreakDelta,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _summaryCard(_summary(l10n, report)),
        ],
      ),
    );
  }

  Widget _heroCard(String title) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.withValues(alpha: .34), Colors.white10],
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
        child: Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _metricCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
      ),
      child: Column(children: children),
    );
  }

  Widget _summaryCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withValues(alpha: .18)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16, height: 1.35)),
    );
  }

  Widget _metric(
    String label,
    int base,
    int compare,
    int delta, {
    String suffix = '',
    bool lowerIsBetter = false,
  }) {
    final improved = lowerIsBetter ? delta < 0 : delta > 0;
    final color = delta == 0
        ? Colors.grey
        : improved
        ? Colors.green
        : Colors.red;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text('$base$suffix → $compare$suffix'),
      trailing: Text(
        '${delta >= 0 ? '+' : ''}$delta$suffix',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _metricDouble(
    String label,
    double base,
    double compare,
    double delta, {
    String suffix = '',
    bool lowerIsBetter = false,
  }) {
    final improved = lowerIsBetter ? delta < 0 : delta > 0;
    final color = delta.abs() < 0.01
        ? Colors.grey
        : improved
        ? Colors.green
        : Colors.red;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(
        '${base.toStringAsFixed(1)}$suffix → ${compare.toStringAsFixed(1)}$suffix',
      ),
      trailing: Text(
        '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)}$suffix',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _summary(AppLocalizations l10n, SessionComparisonReport report) {
    final positives = <String>[];
    final negatives = <String>[];
    if (report.totalDelta > 0) positives.add(l10n.fishCount);
    if (report.triesDelta < 0) positives.add(l10n.tryCount);
    if (report.stabilityDelta > 0) positives.add(l10n.stabilityScore);
    if (report.totalDelta < 0) negatives.add(l10n.fishCount);
    if (report.triesDelta > 0) negatives.add(l10n.tryCount);
    if (report.stabilityDelta < 0) negatives.add(l10n.stabilityScore);

    if (positives.isEmpty && negatives.isEmpty)
      return l10n.comparisonNoMajorChanges;
    return '${l10n.improved}: ${positives.isEmpty ? '-' : positives.join(', ')}\n'
        '${l10n.needsAttention}: ${negatives.isEmpty ? '-' : negatives.join(', ')}';
  }
}
