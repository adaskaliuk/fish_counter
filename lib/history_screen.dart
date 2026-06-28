// ==========================================
// HISTORY AND ANALYTICS
// ==========================================
import 'package:fish_counter/analytics_screen.dart';
import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/historical_catch_tuning_report.dart';
import 'package:fish_counter/progress_screen.dart';
import 'package:fish_counter/session_comparison_screen.dart';
import 'package:fish_counter/services/cloud_history_service.dart';
import 'package:fish_counter/services/prefs_repository.dart';
import 'package:fish_counter/utils/error_handler.dart';
import 'package:fish_counter/widgets/history_session_details.dart';
import 'package:fish_counter/widgets/session_edit_dialog.dart';
import 'package:fish_counter/widgets/sync_badge_button.dart';
import 'package:fish_counter/widgets/sync_status_banner.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  final VoidCallback onHistoryUpdate;

  const HistoryScreen({super.key, required this.onHistoryUpdate});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with WidgetsBindingObserver {
  List<GameSession> _sessions = [];
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _error;
  String? _syncWarning;
  String _syncError = '';
  bool _syncPending = false;
  bool _compareMode = false;
  final Set<String> _selectedForCompare = {};
  final Map<String, HistoricalCatchTuningReport> _tuningBySessionId = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSessions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _retryPendingSync();
  }

  Future<void> _retryPendingSync() async {
    if (!_syncPending || _isSyncing || _isLoading) return;
    await _syncNow();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _syncWarning = null;
    });

    try {
      final repo = await PrefsRepository.create();
      var container = await repo.loadInitialState();
      Object? syncError;
      if (container.syncHistoryEnabled) {
        try {
          await CloudHistoryService().syncLocalAndRemote(repo);
          container = await repo.loadInitialState();
        } catch (e) {
          syncError = e;
          await repo.saveSyncStatus(status: 'failed', error: e.toString());
          container = await repo.loadInitialState();
          debugPrint('Cloud history load error: $e');
        }
      } else {
        await repo.saveSyncStatus(status: 'off');
      }

      if (!mounted) return;

      final sessions = container.historySessions.cast<GameSession>().toList();
      _rebuildTuning(sessions);

      setState(() {
        _sessions = sessions.reversed.toList(); // Display newest first
        _syncWarning = syncError == null
            ? null
            : '${AppLocalizations.of(context).cloudSyncFailed}: $syncError';
        _syncError = repo.getSyncLastError();
        _syncPending = repo.isSyncPending();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error =
            '${AppLocalizations.of(context).errorLoadingHistory}: ${e.toString()}';
        _isLoading = false;
      });
      debugPrint('Error loading history: $e');
    }
  }

  Future<void> _syncNow() async {
    setState(() {
      _isSyncing = true;
      _syncWarning = null;
    });

    final repo = await PrefsRepository.create();
    try {
      await CloudHistoryService().syncLocalAndRemote(repo);
      final state = await repo.loadInitialState();
      _rebuildTuning(state.historySessions.cast<GameSession>().toList());
      if (!mounted) return;
      setState(() {
        _sessions = state.historySessions.reversed.toList();
        _syncError = repo.getSyncLastError();
        _syncPending = repo.isSyncPending();
        _isSyncing = false;
      });
    } catch (e) {
      await repo.saveSyncStatus(status: 'failed', error: e.toString());
      final state = await repo.loadInitialState();
      final sessions = state.historySessions.cast<GameSession>().toList();
      _rebuildTuning(sessions);
      if (!mounted) return;
      setState(() {
        _sessions = sessions.reversed.toList();
        _syncError = repo.getSyncLastError();
        _syncPending = repo.isSyncPending();
        _syncWarning = '${AppLocalizations.of(context).cloudSyncFailed}: $e';
        _isSyncing = false;
      });
    }
  }

  Future<void> _refreshLocalSessions() async {
    final repo = await PrefsRepository.create();
    final state = await repo.loadInitialState();
    if (!mounted) return;

    final sessions = state.historySessions.cast<GameSession>().toList();
    _rebuildTuning(sessions);

    setState(() {
      _sessions = sessions.reversed.toList();
      _syncError = repo.getSyncLastError();
      _syncPending = repo.isSyncPending();
    });
  }

  Widget _syncErrorBanner() {
    if (_syncError.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    return SyncStatusBanner(
      title: l10n.cloudSyncFailed,
      message: _syncError,
    );
  }

  Future<void> _deleteSession(GameSession session) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ErrorHandler.showConfirmDialog(
      context,
      l10n.deleteSessionQuestion,
      l10n.deleteSessionWarning,
    );

    if (!confirmed) return;

    Object? syncError;
    try {
      final repo = await PrefsRepository.create();
      final syncEnabled = await repo.isSyncHistoryEnabled();
      await repo.deleteHistorySession(session.id);

      if (syncEnabled) {
        try {
          await CloudHistoryService().deleteSession(session.id);
        } catch (e) {
          syncError = e;
          debugPrint('Cloud history delete error: $e');
        }
      }

      if (!mounted) return;
      await _refreshLocalSessions();
      if (!mounted) return;
      setState(() {
        _syncWarning = syncError == null
            ? null
            : '${AppLocalizations.of(context).cloudDeleteFailed}: $syncError';
      });
      widget.onHistoryUpdate();
      // ignore: use_build_context_synchronously
      ErrorHandler.showSuccess(context, l10n.sessionDeleted);
    } catch (e) {
      debugPrint('Error deleting session: $e');
      if (!mounted) return;
      ErrorHandler.showError(context, '${l10n.deleteSession}: $e');
    }
  }

  Future<void> _editSession(GameSession session) async {
    final l10n = AppLocalizations.of(context);

    final updated = await SessionEditDialog.show(context, session);

    if (updated == null) return;

    Object? syncError;
    try {
      final repo = await PrefsRepository.create();
      final syncEnabled = await repo.isSyncHistoryEnabled();
      await repo.updateHistorySession(updated);
      if (syncEnabled) {
        try {
          await CloudHistoryService().uploadSession(updated);
        } catch (e) {
          syncError = e;
          debugPrint('Cloud history update error: $e');
        }
      }
      if (!mounted) return;
      await _refreshLocalSessions();
      if (!mounted) return;
      setState(() {
        _syncWarning = syncError == null
            ? null
            : '${AppLocalizations.of(context).cloudUpdateFailed}: $syncError';
      });
      widget.onHistoryUpdate();
      // ignore: use_build_context_synchronously
      ErrorHandler.showSuccess(context, l10n.save);
    } catch (e) {
      debugPrint('Error updating session: $e');
      if (!mounted) return;
      ErrorHandler.showError(context, '${l10n.editSession}: $e');
    }
  }

  void _toggleCompareSelection(GameSession session) {
    setState(() {
      if (_selectedForCompare.contains(session.id)) {
        _selectedForCompare.remove(session.id);
      } else if (_selectedForCompare.length < 2) {
        _selectedForCompare.add(session.id);
      }
    });
  }

  void _openComparison() {
    if (_selectedForCompare.length != 2) return;
    final selected = _sessions
        .where((session) => _selectedForCompare.contains(session.id))
        .toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SessionComparisonScreen(
          base: selected.last,
          compare: selected.first,
        ),
      ),
    );
  }

  void _openProgress() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProgressScreen(sessions: _sessions)),
    );
  }

  void _rebuildTuning(List<GameSession> sessions) {
    _tuningBySessionId.clear();
    final ordered = sessions.toList();
    for (final session in ordered) {
      _tuningBySessionId[session.id] =
          HistoricalCatchTuningReport.fromSessions(ordered
              .takeWhile((item) => item.id != session.id)
              .toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_compareMode ? l10n.selectTwoSessions : l10n.history),
        actions: [
          if (_syncPending || _isSyncing)
            SyncBadgeButton(
              tooltip: l10n.syncNow,
              isLoading: _isSyncing,
              onPressed: _isSyncing ? null : _syncNow,
            ),
          if (_compareMode)
            TextButton(
              onPressed: _selectedForCompare.length == 2
                  ? _openComparison
                  : null,
              child: Text(l10n.compare),
            ),
          IconButton(
            icon: Icon(_compareMode ? Icons.close : Icons.compare_arrows),
            onPressed: () => setState(() {
              _compareMode = !_compareMode;
              _selectedForCompare.clear();
            }),
          ),
          IconButton(
            tooltip: l10n.progressTrends,
            icon: const Icon(Icons.insights),
            onPressed: _sessions.isEmpty ? null : _openProgress,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadSessions,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade700),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSessions,
              child: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
      );
    }

    if (_sessions.isEmpty) {
      return ListView(
        children: [
          _syncErrorBanner(),
          if (_syncWarning != null)
            ListTile(
              leading: const Icon(Icons.cloud_off, color: Colors.orange),
              title: Text(_syncWarning!),
              subtitle: Text(AppLocalizations.of(context).retry),
              onTap: _loadSessions,
            ),
          const SizedBox(height: 96),
          Center(
            child: Column(
              children: [
                Icon(Icons.history, size: 48, color: Colors.grey.shade600),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).noSessionsYet,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: _sessions.length + (_syncWarning == null ? 0 : 1),
      itemBuilder: (context, index) {
        if (_syncWarning != null && index == 0) {
          return ListTile(
            leading: const Icon(Icons.cloud_off, color: Colors.orange),
            title: Text(_syncWarning!),
            subtitle: Text(AppLocalizations.of(context).retry),
            onTap: _loadSessions,
          );
        }

        final warningOffset = _syncWarning == null ? 0 : 1;
        final sessionIndex = index - warningOffset;
        final session = _sessions[sessionIndex];
        final selected = _selectedForCompare.contains(session.id);
        return ListTile(
          leading: _compareMode
              ? Checkbox(
                  value: selected,
                  onChanged: (_) => _toggleCompareSelection(session),
                )
              : null,
          title: Text(session.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${AppLocalizations.of(context).date}: ${session.date} | ${AppLocalizations.of(context).duration}: ${session.matchDuration}',
              ),
              const SizedBox(height: 8),
              HistorySessionDetails(
                session: session,
                l10n: AppLocalizations.of(context),
              ),
            ],
          ),
          trailing: _compareMode
              ? null
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: AppLocalizations.of(context).editSession,
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _editSession(session),
                    ),
                    IconButton(
                      tooltip: AppLocalizations.of(context).deleteSession,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteSession(session),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
          onTap: _compareMode
              ? () => _toggleCompareSelection(session)
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => AnalyticsScreen(
                        session: session,
                        tuning: _tuningBySessionId[session.id],
                      ),
                    ),
                  ),
        );
      },
    );
  }

}
