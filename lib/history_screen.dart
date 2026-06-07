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
  String? _error;
  String? _syncWarning;

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
      var container = await PrefsRepository.loadState();
      Object? syncError;
      if (container.syncHistoryEnabled) {
        try {
          final cloudSessions = await CloudHistoryService().loadSessions();
          if (cloudSessions.isNotEmpty) {
            final repo = await PrefsRepository.create();
            await repo.mergeHistorySessions(cloudSessions);
            container = await repo.loadInitialState();
          }
        } catch (e) {
          syncError = e;
          debugPrint('Cloud history load error: $e');
        }
      }

      if (!mounted) return;

      final sessions = container.historySessions.cast<GameSession>().toList();

      setState(() {
        _sessions = sessions.reversed.toList(); // Display newest first
        _syncWarning = syncError == null
            ? null
            : 'Cloud sync failed: $syncError';
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 48, color: Colors.grey.shade600),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).noSessionsYet,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
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

        final sessionIndex = index - (_syncWarning == null ? 0 : 1);
        final session = _sessions[sessionIndex];
        return ListTile(
          title: Text(session.name),
          subtitle: Text(
            '${AppLocalizations.of(context).date}: ${session.date} | ${AppLocalizations.of(context).duration}: ${session.matchDuration}',
          ),
          trailing: const Icon(Icons.chevron_right),
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
