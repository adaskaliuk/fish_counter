import 'package:fish_counter/constants.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/activity_log.dart';
import 'package:flutter/material.dart';

class ActivityHeatmapCard extends StatelessWidget {
  const ActivityHeatmapCard({
    super.key,
    required this.logs,
    required this.l10n,
  });

  final List<ActivityLog> logs;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) return const SizedBox.shrink();

    const columns = 12;
    final rows = <List<ActivityLog>>[];
    for (var i = 0; i < logs.length; i += columns) {
      final end = i + columns > logs.length ? logs.length : i + columns;
      rows.add(logs.sublist(i, end));
    }

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
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: .08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.activityHeatmap,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${logs.length}',
                  style: const TextStyle(
                    color: Colors.lightGreenAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final row in rows) ...[
                  Row(
                    children: [
                      for (final log in row)
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Tooltip(
                              message:
                                  '${log.timestamp} • ${_statusLabel(log.status)} • ${log.interval.inSeconds}s',
                              child: Container(
                                margin: const EdgeInsets.all(1.5),
                                decoration: BoxDecoration(
                                  color: log.status.toColor().withValues(
                                    alpha: log.status == Status.pause
                                        ? .35
                                        : .9,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: .10),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: log.status.toColor().withValues(
                                        alpha: log.status == Status.pause
                                            ? .08
                                            : .18,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      for (var i = row.length; i < columns; i++)
                        const Expanded(
                          child: AspectRatio(aspectRatio: 1, child: SizedBox()),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _legendItem(l10n.green, Colors.green.shade700),
                    _legendItem(l10n.orange, Colors.orange.shade800),
                    _legendItem(l10n.red, Colors.red.shade800),
                    _legendItem(l10n.grey, Colors.grey.shade700),
                    _legendItem(l10n.pauseReset, Colors.blueGrey.shade600),
                  ],
                ),
                const SizedBox(height: 2),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.activityTimeline,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .38),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(Status status) {
    switch (status) {
      case Status.perfect:
      case Status.good:
        return l10n.green;
      case Status.average:
        return l10n.orange;
      case Status.poor:
        return l10n.red;
      case Status.early:
        return l10n.grey;
      case Status.pause:
        return l10n.pauseReset;
    }
  }

  Widget _legendItem(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
