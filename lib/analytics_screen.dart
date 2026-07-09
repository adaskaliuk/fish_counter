// ANALYTICS SCREEN
import 'package:fish_counter/constants.dart';
import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/activity_log.dart';
import 'package:fish_counter/models/analytics_report.dart';
import 'package:fish_counter/models/athlete_profile.dart';
import 'package:fish_counter/models/historical_catch_tuning_report.dart';
import 'package:fish_counter/services/prefs_repository.dart';
import 'package:fish_counter/services/report_exporter.dart';
import 'package:fish_counter/widgets/analytics_screen_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

List<ActivityLog> _activityLogs(List<Map<String, dynamic>> grid) {
  return grid
      .map((entry) => ActivityLog.fromJson(Map<String, dynamic>.from(entry)))
      .where((log) => log.type != ActivityType.unknown)
      .toList(growable: false);
}

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key, required this.session, this.tuning});

  final GameSession session;
  final HistoricalCatchTuningReport? tuning;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final report = AnalyticsReport.fromGrid(session.grid);
    final activityLogs = _activityLogs(session.grid);

    return FutureBuilder<AthleteProfile>(
      future: PrefsRepository.create().then((r) => r.loadAthleteProfile()),
      builder: (context, roleSnapshot) {
        final isCoach = roleSnapshot.data?.isCoach ?? false;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.precisionReport),
            actions: [
              IconButton(
                icon: const Icon(Icons.ios_share),
                onPressed: () => _showExportOptions(context, isCoach),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showInfoDialog(context),
              ),
            ],
          ),
          body: AnalyticsScreenBody(
            session: session,
            report: report,
            activityLogs: activityLogs,
            l10n: l10n,
            tuning: tuning,
            isCoach: isCoach,
          ),
        );
      },
    );
  }

  void _showExportOptions(BuildContext context, bool isCoach) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 420),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.ios_share),
              title: Text(l10n.precisionReport),
              subtitle: Text(session.name),
            ),
            ListTile(
              leading: const Icon(Icons.ios_share),
              title: Text(l10n.shareTextReport),
              onTap: () {
                Navigator.pop(sheetContext);
                _shareTextReport(context, isCoach);
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: Text(l10n.shareCsvReport),
              onTap: () {
                Navigator.pop(sheetContext);
                _shareCsvReport(context, isCoach);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text(l10n.copyCsvReport),
              onTap: () {
                Navigator.pop(sheetContext);
                _copyCsvReport(context, isCoach);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareTextReport(BuildContext context, bool isCoach) async {
    final l10n = AppLocalizations.of(context);
    await _shareOrCopy(
      context,
      text: ReportExporter.buildPlainText(
        session,
        l10n: l10n,
        tuning: tuning,
        isCoach: isCoach,
      ),
      debugLabel: l10n.shareTextReport,
      successMessage: l10n.reportShared,
      fallbackMessage: l10n.reportCopied,
    );
  }

  Future<void> _shareCsvReport(BuildContext context, bool isCoach) async {
    final l10n = AppLocalizations.of(context);
    await _shareOrCopy(
      context,
      text: ReportExporter.buildCsv(
        session,
        l10n: l10n,
        tuning: tuning,
        isCoach: isCoach,
      ),
      debugLabel: l10n.shareCsvReport,
      successMessage: l10n.csvShared,
      fallbackMessage: l10n.csvCopied,
    );
  }

  Future<void> _copyCsvReport(BuildContext context, bool isCoach) async {
    final l10n = AppLocalizations.of(context);
    await Clipboard.setData(
      ClipboardData(
        text: ReportExporter.buildCsv(
          session,
          l10n: l10n,
          tuning: tuning,
          isCoach: isCoach,
        ),
      ),
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
    required String successMessage,
    required String fallbackMessage,
  }) async {
    try {
      final result = await SharePlus.instance.share(
        ShareParams(subject: session.name, text: text),
      );
      if (result.status == ShareResultStatus.success) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(successMessage)));
        return;
      }
      if (result.status == ShareResultStatus.dismissed) return;
    } catch (e) {
      debugPrint('$debugLabel error: $e');
    }

    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(fallbackMessage)));
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
