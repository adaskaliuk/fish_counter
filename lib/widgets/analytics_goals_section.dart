import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/analytics_report.dart';
import 'package:flutter/material.dart';

class AnalyticsGoalsSection extends StatelessWidget {
  const AnalyticsGoalsSection({
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
    if (!_hasGoals()) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Text(
          l10n.trainingGoals,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 10),
        _contextRow(
          l10n.fishCount,
          _goalStatus(
            session.total,
            session.goalFishCount,
            higherIsBetter: true,
            notSet: l10n.notSet,
          ),
        ),
        _contextRow(
          l10n.tryCount,
          _goalStatus(
            session.tries,
            session.goalMaxTries,
            higherIsBetter: false,
            notSet: l10n.notSet,
          ),
        ),
        _contextRow(
          l10n.stabilityScore,
          _goalStatus(
            report.stabilityScore,
            session.goalStabilityPercent,
            higherIsBetter: true,
            notSet: l10n.notSet,
            suffix: '%',
          ),
        ),
        _contextRow(
          l10n.avgPace,
          _goalStatus(
            report.averageInterval.round(),
            session.goalTargetPaceSeconds,
            higherIsBetter: false,
            notSet: l10n.notSet,
            suffix: 's',
          ),
        ),
      ],
    );
  }

  bool _hasGoals() {
    return session.goalFishCount > 0 ||
        session.goalTargetPaceSeconds > 0 ||
        session.goalMaxTries > 0 ||
        session.goalStabilityPercent > 0;
  }

  String _goalStatus(
    int actual,
    int goal, {
    required bool higherIsBetter,
    required String notSet,
    String suffix = '',
  }) {
    if (goal <= 0) return notSet;
    final achieved = higherIsBetter ? actual >= goal : actual <= goal;
    return '${achieved ? '✅' : '❌'} $actual$suffix / $goal$suffix';
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
