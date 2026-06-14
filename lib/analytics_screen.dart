// ==========================================
// ANALYTICS SCREEN
// ==========================================
import 'package:fish_counter/constants.dart';
import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/analytics_report.dart';
import 'package:fish_counter/services/report_exporter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class AnalyticsScreen extends StatelessWidget {
  final GameSession session;

  const AnalyticsScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final report = AnalyticsReport.fromGrid(session.grid);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.precisionReport),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            onPressed: () => _showExportOptions(context),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
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
              _buildTrainingContext(l10n),
              const SizedBox(height: 25),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statBox('C1', session.c1),
                _statBox('TOTAL', session.total, isHero: true),
                _statBox('C2', session.c2),
              ],
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  _avgIndicator(
                    l10n.avgVibe,
                    '${report.averageInterval.toStringAsFixed(1)}s',
                    Colors.white,
                  ),
                  Container(width: 1, height: 30, color: Colors.white24),
                  _avgIndicator(
                    l10n.deviation,
                    '${report.averageDeviation > 0 ? '+' : ''}${report.averageDeviation.toStringAsFixed(2)}s',
                    report.averageDeviation.abs() < 1.5
                        ? Colors.green
                        : report.averageDeviation.abs() < 4
                        ? Colors.orange
                        : Colors.red,
                  ),
                ],
              ),
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
            _buildCoachSummary(report, l10n),
            if (_hasGoals()) ...[
              const SizedBox(height: 30),
              Text(
                l10n.trainingGoals,
                style: TextStyle(
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
            const SizedBox(height: 30),
            if (session.athleteNote.isNotEmpty ||
                session.coachComment.isNotEmpty) ...[
              Text(
                l10n.sessionNotes,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 10),
              if (session.athleteNote.isNotEmpty)
                _noteBox(l10n.athleteNote, session.athleteNote),
              if (session.coachComment.isNotEmpty)
                _noteBox(l10n.coachComment, session.coachComment),
              const SizedBox(height: 20),
            ],
            Text(
              l10n.activityTimeline,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 10),
            if (session.grid.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    l10n.noActivityRecorded,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: session.grid.length,
                itemBuilder: (context, index) {
                  final entry = session.grid[index];
                  final type = ActivityType.fromValue(_toInt(entry['type']));
                  final status = type == ActivityType.manualPause
                      ? Status.pause
                      : _statusFromRaw(entry['status']);

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(_iconForType(type), color: status.toColor()),
                    title: Text(
                      _labelForType(type, l10n),
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      entry['timestamp']?.toString() ?? '--:--:--',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: type != ActivityType.manualPause
                        ? Text(
                            '${_toInt(entry['interval'])}s',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )
                        : const Text('-', style: TextStyle(color: Colors.grey)),
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
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

  Widget _buildTrainingContext(AppLocalizations l10n) {
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

  Widget _buildCoachSummary(AnalyticsReport report, AppLocalizations l10n) {
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

  Widget _noteBox(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(value),
        ],
      ),
    );
  }

  Widget _statBox(String label, int value, {bool isHero = false}) {
    return Container(
      constraints: const BoxConstraints(minWidth: 80),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isHero ? Colors.orange.withValues(alpha: 0.18) : Colors.white10,
        borderRadius: BorderRadius.circular(14),
        border: isHero ? Border.all(color: Colors.orange, width: 1.5) : null,
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: TextStyle(
              color: isHero ? Colors.orange : Colors.white,
              fontSize: isHero ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _avgIndicator(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 4),
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
    );
  }

  void _showExportOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.ios_share),
              title: Text(l10n.shareTextReport),
              onTap: () {
                Navigator.pop(sheetContext);
                _shareTextReport(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: Text(l10n.shareCsvReport),
              onTap: () {
                Navigator.pop(sheetContext);
                _shareCsvReport(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text(l10n.copyCsvReport),
              onTap: () {
                Navigator.pop(sheetContext);
                _copyCsvReport(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareTextReport(BuildContext context) async {
    await _shareOrCopy(
      context,
      text: ReportExporter.buildPlainText(session),
      debugLabel: 'Share text report',
    );
  }

  Future<void> _shareCsvReport(BuildContext context) async {
    await _shareOrCopy(
      context,
      text: ReportExporter.buildCsv(session),
      debugLabel: 'Share CSV report',
    );
  }

  Future<void> _copyCsvReport(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    await Clipboard.setData(
      ClipboardData(text: ReportExporter.buildCsv(session)),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.csvCopied)));
  }

  Future<void> _shareOrCopy(
    BuildContext context, {
    required String text,
    required String debugLabel,
  }) async {
    final l10n = AppLocalizations.of(context);

    try {
      final result = await SharePlus.instance.share(
        ShareParams(subject: session.name, text: text),
      );
      if (result.status != ShareResultStatus.unavailable) return;
    } catch (e) {
      debugPrint('$debugLabel error: $e');
    }

    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.reportCopied)));
  }

  void _showInfoDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.precisionGuide),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(
              status: l10n.green,
              color: Colors.green,
              description: l10n.greenDescription,
            ),
            _InfoRow(
              status: l10n.orange,
              color: Colors.orange,
              description: l10n.orangeDescription,
            ),
            _InfoRow(
              status: l10n.red,
              color: Colors.red,
              description: l10n.redDescription,
            ),
            _InfoRow(
              status: l10n.grey,
              color: Colors.grey,
              description: l10n.greyDescription,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.ok)),
        ],
      ),
    );
  }

  IconData _iconForType(ActivityType type) {
    switch (type) {
      case ActivityType.manualPause:
        return Icons.pause_circle_filled;
      case ActivityType.c1Click:
        return Icons.stop;
      case ActivityType.c2Click:
        return Icons.change_history;
      case ActivityType.tryClick:
      case ActivityType.unknown:
        return Icons.circle;
    }
  }

  String _labelForType(ActivityType type, AppLocalizations l10n) {
    switch (type) {
      case ActivityType.manualPause:
        return l10n.pauseReset;
      case ActivityType.c1Click:
        return l10n.c1Click;
      case ActivityType.c2Click:
        return l10n.c2Click;
      case ActivityType.tryClick:
        return l10n.tryError;
      case ActivityType.unknown:
        return l10n.unknown;
    }
  }

  Status _statusFromRaw(dynamic value) {
    final raw = value?.toString();
    switch (raw) {
      case 'green':
        return Status.perfect;
      case 'red':
        return Status.poor;
      case 'grey':
        return Status.early;
      case 'orange':
        return Status.average;
      default:
        return Status.fromName(raw);
    }
  }

  static int _toInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? defaultValue;
  }
}

class _InfoRow extends StatelessWidget {
  final String status;
  final Color color;
  final String description;

  const _InfoRow({
    required this.status,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text('$status: $description'),
        ],
      ),
    );
  }
}
