import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/activity_log.dart';
import 'package:fish_counter/models/analytics_report.dart';
import 'package:fish_counter/models/historical_catch_tuning_report.dart';
import 'package:flutter/material.dart';

import 'analytics_coach_dashboard_section.dart';
import 'analytics_dashboard_section.dart';
import 'analytics_charts_section.dart';
import 'analytics_timeline_section.dart';
import 'analytics_weather_section.dart';
import 'weather_during_match_section.dart';

class AnalyticsScreenBody extends StatelessWidget {
  const AnalyticsScreenBody({
    super.key,
    required this.session,
    required this.report,
    required this.activityLogs,
    required this.l10n,
    required this.isCoach,
    this.tuning,
  });

  final GameSession session;
  final AnalyticsReport report;
  final List<ActivityLog> activityLogs;
  final AppLocalizations l10n;
  final bool isCoach;
  final HistoricalCatchTuningReport? tuning;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnalyticsDashboardSection(
            session: session,
            report: report,
            activityLogs: activityLogs,
            l10n: l10n,
            isCoach: isCoach,
            tuning: tuning,
          ),
          if (isCoach) ...[
            const SizedBox(height: 24),
            AnalyticsCoachDashboardSection(
              session: session,
              report: report,
              l10n: l10n,
              tuning: tuning,
            ),
            const SizedBox(height: 24),
            AnalyticsWeatherSection(session: session, l10n: l10n),
            const SizedBox(height: 24),
          ],
          AnalyticsTimelineSection(activityLogs: activityLogs, l10n: l10n),
          WeatherDuringMatchSection(session: session, l10n: l10n),
          AnalyticsChartsSection(
            session: session,
            report: report,
            activityLogs: activityLogs,
            l10n: l10n,
          ),
        ],
      ),
    );
  }
}
