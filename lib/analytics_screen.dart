// ANALYTICS SCREEN
import 'package:fish_counter/constants.dart';
import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/activity_log.dart';
import 'package:fish_counter/models/analytics_report.dart';
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
  const AnalyticsScreen({super.key, required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final report = AnalyticsReport.fromGrid(session.grid);
    final activityLogs = _activityLogs(session.grid);

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
      body: AnalyticsScreenBody(
        session: session,
        report: report,
        activityLogs: activityLogs,
        l10n: l10n,
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
    final l10n = AppLocalizations.of(context);
    await _shareOrCopy(
      context,
      text: ReportExporter.buildPlainText(session, l10n: l10n),
      debugLabel: l10n.shareTextReport,
    );
  }

  Future<void> _shareCsvReport(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    await _shareOrCopy(
      context,
      text: ReportExporter.buildCsv(session, l10n: l10n),
      debugLabel: l10n.shareCsvReport,
    );
  }

  Future<void> _copyCsvReport(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    await Clipboard.setData(
      ClipboardData(text: ReportExporter.buildCsv(session, l10n: l10n)),
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
