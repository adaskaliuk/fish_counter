import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/activity_log.dart';
import 'package:fish_counter/models/analytics_report.dart';
import 'package:flutter/material.dart';

import 'analytics_charts_section.dart';
import 'analytics_goals_section.dart';
import 'analytics_notes_section.dart';
import 'analytics_summary_section.dart';
import 'analytics_timeline_section.dart';

class AnalyticsScreenBody extends StatelessWidget {
  const AnalyticsScreenBody({
    super.key,
    required this.session,
    required this.report,
    required this.activityLogs,
    required this.l10n,
  });

  final GameSession session;
  final AnalyticsReport report;
  final List<ActivityLog> activityLogs;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnalyticsSummarySection(session: session, report: report, l10n: l10n),
          AnalyticsChartsSection(
            session: session,
            report: report,
            activityLogs: activityLogs,
            l10n: l10n,
          ),
          AnalyticsGoalsSection(session: session, report: report, l10n: l10n),
          AnalyticsNotesSection(session: session, l10n: l10n),
          AnalyticsTimelineSection(
            activityLogs: activityLogs,
            l10n: l10n,
          ),
        ],
      ),
    );
  }
}
