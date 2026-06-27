import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/analytics_report.dart';
import 'package:fish_counter/models/historical_catch_tuning_report.dart';
import 'package:flutter/material.dart';

class AnalyticsCoachDashboardSection extends StatelessWidget {
  const AnalyticsCoachDashboardSection({
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
    final signals = _signals();
    final focus = _pickLowest(signals);
    final strength = _pickHighest(signals);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.coachSummary,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _compactSignal(l10n.needsAttention, focus, Colors.orange)),
                  const SizedBox(width: 8),
                  Expanded(child: _compactSignal(l10n.improved, strength, Colors.green)),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (session.goalFishCount > 0)
                    _targetChip(l10n.targetFishCount, '${session.goalFishCount}'),
                  if (session.goalTargetPaceSeconds > 0)
                    _targetChip(
                      l10n.targetPaceSeconds,
                      '${session.goalTargetPaceSeconds}s',
                    ),
                  if (session.goalMaxTries > 0)
                    _targetChip(l10n.maxTries, session.goalMaxTries.toString()),
                  if (session.goalStabilityPercent > 0)
                    _targetChip(
                      l10n.stabilityTarget,
                      '${session.goalStabilityPercent}%',
                    ),
                ],
              ),
              if (tuning != null && !tuning!.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${l10n.historicalTuning}: ${_localizedTuningSummary()}',
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

  List<_Signal> _signals() {
    final signals = <_Signal>[
      if (session.goalFishCount > 0)
        _Signal(
          label: l10n.fishCount,
          detail: '${session.total}/${session.goalFishCount}',
          score: session.total / session.goalFishCount * 100,
          weight: tuning?.fishCountWeight ?? 1,
        ),
      _Signal(
        label: l10n.stabilityScore,
        detail: session.goalStabilityPercent > 0
            ? '${report.stabilityScore}% / ${session.goalStabilityPercent}%'
            : '${report.stabilityScore}%',
        score: session.goalStabilityPercent > 0
            ? report.stabilityScore / session.goalStabilityPercent * 100
            : report.stabilityScore.toDouble(),
        weight: tuning?.stabilityWeight ?? 1,
      ),
      if (session.goalTargetPaceSeconds > 0 && report.averageInterval > 0)
        _Signal(
          label: l10n.avgPace,
          detail:
              '${report.averageInterval.toStringAsFixed(1)}s / ${session.goalTargetPaceSeconds}s',
          score: 100 -
              ((report.averageInterval - session.goalTargetPaceSeconds).abs() /
                      session.goalTargetPaceSeconds) *
                  100,
          weight: tuning?.paceWeight ?? 1,
        ),
      if (session.goalMaxTries > 0)
        _Signal(
          label: l10n.maxTries,
          detail: '${session.tries}/${session.goalMaxTries}',
          score: 100 - (session.tries / session.goalMaxTries) * 100,
          weight: tuning?.triesWeight ?? 1,
        ),
    ];

    if (signals.isEmpty) {
      return [
        _Signal(
          label: l10n.readinessScore,
          detail: '${report.stabilityScore}%',
          score: report.stabilityScore.toDouble(),
          weight: 1,
        ),
      ];
    }

    return signals;
  }

  _Signal _pickLowest(List<_Signal> signals) {
    return signals.reduce((a, b) {
      final aGap = (100 - a.score) * a.weight;
      final bGap = (100 - b.score) * b.weight;
      return bGap > aGap ? b : a;
    });
  }

  _Signal _pickHighest(List<_Signal> signals) {
    return signals.reduce((a, b) {
      final aScore = a.score * a.weight;
      final bScore = b.score * b.weight;
      return bScore > aScore ? b : a;
    });
  }

  Widget _compactSignal(
    String label,
    _Signal signal,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9)),
          const SizedBox(height: 4),
          Text(
            signal.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            signal.detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _targetChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: Colors.white70, fontSize: 10),
      ),
    );
  }

  String _localizedTuningSummary() {
    final tuning = this.tuning;
    if (tuning == null) return '';
    return [
      '${l10n.fishCount} ${tuning.fishCountWeight.toStringAsFixed(2)}×',
      '${l10n.stabilityScore} ${tuning.stabilityWeight.toStringAsFixed(2)}×',
      '${l10n.maxTries} ${tuning.triesWeight.toStringAsFixed(2)}×',
      '${l10n.avgPace} ${tuning.paceWeight.toStringAsFixed(2)}×',
    ].join(' • ');
  }
}

class _Signal {
  final String label;
  final String detail;
  final double score;
  final double weight;

  const _Signal({
    required this.label,
    required this.detail,
    required this.score,
    required this.weight,
  });
}
