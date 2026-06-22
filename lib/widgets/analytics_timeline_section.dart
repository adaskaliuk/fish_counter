import 'package:fish_counter/constants.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/activity_log.dart';
import 'package:flutter/material.dart';

class AnalyticsTimelineSection extends StatelessWidget {
  const AnalyticsTimelineSection({
    super.key,
    required this.activityLogs,
    required this.l10n,
  });

  final List<ActivityLog> activityLogs;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.activityTimeline,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 10),
        if (activityLogs.isEmpty)
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
            itemCount: activityLogs.length,
            itemBuilder: (context, index) {
              final log = activityLogs[index];
              final status = log.type == ActivityType.manualPause ? Status.pause : log.status;

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(_iconForType(log.type), color: status.toColor()),
                title: Text(
                  _labelForType(log.type),
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  log.timestamp,
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: log.type != ActivityType.manualPause
                    ? Text(
                        '${log.interval.inSeconds}s',
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

  String _labelForType(ActivityType type) {
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
}
