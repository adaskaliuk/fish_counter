import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class SessionCard extends StatelessWidget {
  final GameSession session;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final bool isSelected;
  final VoidCallback? onSelect;

  const SessionCard({
    super.key,
    required this.session,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
    this.isSelected = false,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Colors.orange.withOpacity(0.1) : null,
      child: ListTile(
        leading: isSelected
            ? const Icon(Icons.check_circle, color: Colors.orange)
            : const Icon(Icons.history),
        title: Text(session.name),
        subtitle: Text('${session.date} • ${session.total} ${l10n.total}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onSelect ?? onTap,
      ),
    );
  }
}

class SyncStatusBanner extends StatelessWidget {
  final String status;
  final String lastSyncAt;
  final String? warning;
  final bool isSyncing;
  final VoidCallback onSync;

  const SyncStatusBanner({
    super.key,
    required this.status,
    required this.lastSyncAt,
    this.warning,
    this.isSyncing = false,
    required this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(_getStatusIcon(), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusText(l10n),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (lastSyncAt.isNotEmpty)
                  Text(
                    '${l10n.lastSync}: $lastSyncAt',
                    style: const TextStyle(fontSize: 12),
                  ),
                if (warning != null)
                  Text(
                    warning!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
              ],
            ),
          ),
          if (!isSyncing)
            IconButton(
              icon: const Icon(Icons.sync, size: 20),
              onPressed: onSync,
            )
          else
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case 'syncing':
        return Colors.blue.withOpacity(0.1);
      case 'success':
        return Colors.green.withOpacity(0.1);
      case 'failed':
        return Colors.red.withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case 'syncing':
        return Icons.sync;
      case 'success':
        return Icons.cloud_done;
      case 'failed':
        return Icons.cloud_off;
      default:
        return Icons.cloud;
    }
  }

  String _getStatusText(AppLocalizations l10n) {
    switch (status) {
      case 'syncing':
        return l10n.syncing;
      case 'success':
        return l10n.synced;
      case 'failed':
        return l10n.syncFailed;
      default:
        return l10n.localOnly;
    }
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
