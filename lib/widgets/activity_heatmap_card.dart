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
                                  color: _cellColor(log.status),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: .26),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _shadowColor(log.status),
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
                    _legendItem(l10n.green, const Color(0xFF23D18B)),
                    _legendItem(l10n.orange, const Color(0xFFFFB020)),
                    _legendItem(l10n.red, const Color(0xFFFF5C5C)),
                    _legendItem(l10n.pauseReset, const Color(0xFF5B7CFF)),
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

  Color _cellColor(Status status) {
    return switch (status) {
      Status.perfect => const Color(0xFF23D18B),
      Status.good => const Color(0xFF23D18B),
      Status.average => const Color(0xFFFFB020),
      Status.poor => const Color(0xFFFF5C5C),
      Status.early => const Color(0xFF5B7CFF),
      Status.pause => const Color(0xFF5B7CFF),
    };
  }

  Color _shadowColor(Status status) {
    return _cellColor(
      status,
    ).withValues(alpha: status == Status.pause ? .16 : .26);
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
        return l10n.pauseReset;
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
