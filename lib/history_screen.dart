// ==========================================
// HISTORY AND ANALYTICS
// ==========================================
import 'package:fish_counter/analytics_screen.dart';
import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/services/cloud_history_service.dart';
import 'package:fish_counter/services/prefs_repository.dart';
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
            : 'Cloud sync failed: $syncError';
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
        _syncWarning = 'Cloud sync failed: $e';
        _isSyncing = false;
      });
    }
  }

  Future<void> _deleteSession(GameSession session) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteSessionQuestion),
        content: Text(l10n.deleteSessionWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

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
            : 'Cloud delete failed: $syncError';
      });
      widget.onHistoryUpdate();
      messenger.showSnackBar(SnackBar(content: Text(l10n.sessionDeleted)));
    } catch (e) {
      debugPrint('Error deleting session: $e');
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('${l10n.deleteSession}: $e')),
      );
    }
  }

  Future<void> _editSession(GameSession session) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final nameCtrl = TextEditingController(text: session.name);
    final athleteCtrl = TextEditingController(text: session.athleteName);
    final coachCtrl = TextEditingController(text: session.coachName);
    final venueCtrl = TextEditingController(text: session.venue);
    final sectorCtrl = TextEditingController(text: session.sectorPeg);
    final trainingCtrl = TextEditingController(text: session.trainingType);
    final methodCtrl = TextEditingController(text: session.fishingMethod);
    final paceCtrl = TextEditingController(text: session.targetPace);
    final conditionsCtrl = TextEditingController(text: session.conditions);
    final baitCtrl = TextEditingController(text: session.baitNotes);
    final athleteNoteCtrl = TextEditingController(text: session.athleteNote);
    final coachCommentCtrl = TextEditingController(text: session.coachComment);

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editSession),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _editField('Session name', nameCtrl),
              _editField(l10n.athleteName, athleteCtrl),
              _editField(l10n.coachName, coachCtrl),
              _editField(l10n.venue, venueCtrl),
              _editField(l10n.sectorPeg, sectorCtrl),
              _editField(l10n.trainingType, trainingCtrl),
              _editField(l10n.fishingMethod, methodCtrl),
              _editField(l10n.targetPace, paceCtrl),
              _editField(l10n.conditions, conditionsCtrl),
              _editField(l10n.baitNotes, baitCtrl),
              _editField(l10n.athleteNote, athleteNoteCtrl, maxLines: 3),
              _editField(l10n.coachComment, coachCommentCtrl, maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (saved != true) return;

    final updated = session.copyWith(
      name: nameCtrl.text.trim().isEmpty ? session.name : nameCtrl.text.trim(),
      athleteName: athleteCtrl.text.trim(),
      coachName: coachCtrl.text.trim(),
      venue: venueCtrl.text.trim(),
      sectorPeg: sectorCtrl.text.trim(),
      trainingType: trainingCtrl.text.trim(),
      fishingMethod: methodCtrl.text.trim(),
      targetPace: paceCtrl.text.trim(),
      conditions: conditionsCtrl.text.trim(),
      baitNotes: baitCtrl.text.trim(),
      athleteNote: athleteNoteCtrl.text.trim(),
      coachComment: coachCommentCtrl.text.trim(),
      updatedAt: DateTime.now().toIso8601String(),
    );

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
            : 'Cloud update failed: $syncError';
      });
      widget.onHistoryUpdate();
      messenger.showSnackBar(SnackBar(content: Text(l10n.save)));
    } catch (e) {
      debugPrint('Error updating session: $e');
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('${l10n.editSession}: $e')),
      );
    }
  }

  Widget _editField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).history),
        actions: [
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
        return ListTile(
          title: Text(session.name),
          subtitle: Text(
            '${AppLocalizations.of(context).date}: ${session.date} | ${AppLocalizations.of(context).duration}: ${session.matchDuration}',
          ),
          trailing: Row(
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
          onTap: () => Navigator.push(
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
