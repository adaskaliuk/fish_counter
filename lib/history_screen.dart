// ==========================================
// HISTORY AND ANALYTICS
// ==========================================
import 'package:fish_counter/analytics_screen.dart';
import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/progress_screen.dart';
import 'package:fish_counter/session_comparison_screen.dart';
import 'package:fish_counter/services/cloud_history_service.dart';
import 'package:fish_counter/services/prefs_repository.dart';
import 'package:fish_counter/utils/error_handler.dart';
import 'package:fish_counter/widgets/history_widgets.dart';
import 'package:fish_counter/widgets/session_edit_dialog.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  final VoidCallback onHistoryUpdate;

  const HistoryScreen({super.key, required this.onHistoryUpdate});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<GameSession> _sessions = [];
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _error;
  String? _syncWarning;
  String _syncStatus = 'localOnly';
  String _lastSyncAt = '';
  bool _compareMode = false;
  final Set<String> _selectedForCompare = {};

  @override
  void initState() {
    super.initState();
    _loadSessions();
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
          debugPrint('Cloud history load error: $e');
        }
      } else {
        await repo.saveSyncStatus(status: 'off');
      }

      if (!mounted) return;

      final sessions = container.historySessions.cast<GameSession>().toList();

      setState(() {
        _sessions = sessions.reversed.toList(); // Display newest first
        _syncWarning = syncError == null
            ? null
            : '${AppLocalizations.of(context).cloudSyncFailed}: $syncError';
        _syncStatus = repo.getSyncLastStatus();
        _lastSyncAt = repo.getSyncLastAt();
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
      _syncStatus = 'syncing';
      _syncWarning = null;
    });

    final repo = await PrefsRepository.create();
    try {
      await CloudHistoryService().syncLocalAndRemote(repo);
      final state = await repo.loadInitialState();
      if (!mounted) return;
      setState(() {
        _sessions = state.historySessions.reversed.toList();
        _syncStatus = repo.getSyncLastStatus();
        _lastSyncAt = repo.getSyncLastAt();
        _isSyncing = false;
      });
    } catch (e) {
      await repo.saveSyncStatus(status: 'failed', error: e.toString());
      if (!mounted) return;
      setState(() {
        _syncStatus = 'failed';
        _lastSyncAt = repo.getSyncLastAt();
        _syncWarning = '${AppLocalizations.of(context).cloudSyncFailed}: $e';
        _isSyncing = false;
      });
    }
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
      setState(() {
        _sessions.removeWhere((item) => item.id == session.id);
        _syncWarning = syncError == null
            ? null
            : '${AppLocalizations.of(context).cloudDeleteFailed}: $syncError';
      });
      widget.onHistoryUpdate();
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
      setState(() {
        final index = _sessions.indexWhere((item) => item.id == updated.id);
        if (index != -1) _sessions[index] = updated;
        _syncWarning = syncError == null
            ? null
            : '${AppLocalizations.of(context).cloudUpdateFailed}: $syncError';
      });
      widget.onHistoryUpdate();
      ErrorHandler.showSuccess(context, l10n.save);
    } catch (e) {
      debugPrint('Error updating session: $e');
      if (!mounted) return;
      ErrorHandler.showError(context, '${l10n.editSession}: $e');
    }
  }

  Widget _syncStatusTile() {
    final l10n = AppLocalizations.of(context);
    final (icon, color, title) = switch (_syncStatus) {
      'off' => (Icons.cloud_off, Colors.grey, l10n.syncOff),
      'synced' => (Icons.cloud_done, Colors.green, l10n.synced),
      'failed' => (Icons.cloud_off, Colors.orange, l10n.syncFailed),
      'syncing' => (Icons.sync, Colors.blue, l10n.syncing),
      _ => (Icons.cloud_queue, Colors.grey, l10n.localOnly),
    };

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: _lastSyncAt.isEmpty
          ? null
          : Text('${l10n.lastSync}: $_lastSyncAt'),
      trailing: TextButton(
        onPressed: _isSyncing ? null : _syncNow,
        child: Text(l10n.syncNow),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_compareMode ? l10n.selectTwoSessions : l10n.history),
        actions: [
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
          IconButton(
            icon: const Icon(Icons.cloud_sync),
            onPressed: _isLoading || _isSyncing ? null : _syncNow,
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
          _syncStatusTile(),
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
      itemCount: _sessions.length + 1 + (_syncWarning == null ? 0 : 1),
      itemBuilder: (context, index) {
        if (index == 0) return _syncStatusTile();

        final warningOffset = _syncWarning == null ? 0 : 1;
        if (_syncWarning != null && index == 1) {
          return ListTile(
            leading: const Icon(Icons.cloud_off, color: Colors.orange),
            title: Text(_syncWarning!),
            subtitle: Text(AppLocalizations.of(context).retry),
            onTap: _loadSessions,
          );
        }

        final sessionIndex = index - 1 - warningOffset;
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
          subtitle: Text(
            '${AppLocalizations.of(context).date}: ${session.date} | ${AppLocalizations.of(context).duration}: ${session.matchDuration}',
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
                    builder: (c) => AnalyticsScreen(session: session),
                  ),
                ),
        );
      },
    );
  }
}
