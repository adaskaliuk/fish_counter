import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_counter/auth_screen.dart';
import 'package:fish_counter/clicker_screen.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/athlete_profile.dart';
import 'package:fish_counter/services/cloud_history_service.dart';
import 'package:fish_counter/services/cloud_settings_service.dart';
import 'package:fish_counter/services/prefs_repository.dart';
import 'package:flutter/material.dart';

abstract final class AuthGateKeys {
  static const loadingScreenKey = ValueKey('auth_gate_loading_screen');
  static const authScreenKey = ValueKey('auth_gate_auth_screen');
  static const startupSyncScreenKey = ValueKey('auth_gate_startup_sync_screen');
  static const clickerScreenKey = ValueKey('auth_gate_clicker_screen');
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<AthleteProfile>? _profileFuture;
  String? _lastUid;
  bool _roleSaved = false;

  Future<AthleteProfile> _loadProfile(String uid) =>
      PrefsRepository.create().then((r) => r.loadAthleteProfile(userId: uid));

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            key: AuthGateKeys.loadingScreenKey,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == null) {
          _profileFuture = null;
          _lastUid = null;
          _roleSaved = false;
          return const AuthScreen(key: AuthGateKeys.authScreenKey);
        }

        final uid = snapshot.data!.uid;
        if (_profileFuture == null || _lastUid != uid) {
          _profileFuture = _loadProfile(uid);
          _lastUid = uid;
          _roleSaved = false;
        }

        return FutureBuilder<AthleteProfile>(
          future: _profileFuture,
          builder: (context, roleSnapshot) {
            if (!roleSnapshot.hasData) {
              return const Scaffold(
                key: AuthGateKeys.loadingScreenKey,
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final profile = roleSnapshot.data!;
            if (profile.role.isEmpty && !_roleSaved) {
              return RoleSetupScreen(
                key: AuthGateKeys.authScreenKey,
                userId: uid,
                onSaved: () => setState(() {
                  _roleSaved = true;
                  _profileFuture = _loadProfile(uid);
                }),
              );
            }
            return const StartupSyncedClickerScreen(
              key: AuthGateKeys.startupSyncScreenKey,
            );
          },
        );
      },
    );
  }
}

class RoleSetupScreen extends StatefulWidget {
  const RoleSetupScreen({super.key, this.userId, this.onSaved});

  final String? userId;
  final VoidCallback? onSaved;

  @override
  State<RoleSetupScreen> createState() => _RoleSetupScreenState();
}

class _RoleSetupScreenState extends State<RoleSetupScreen> {
  String? _role;
  bool _saving = false;

  Future<void> _saveRole() async {
    if (_role == null) return;
    setState(() => _saving = true);
    final repo = await PrefsRepository.create();
    // Preserve existing profile fields; only mutate role.
    final existing = repo.loadAthleteProfile(userId: widget.userId);
    await repo.saveAthleteProfile(
      existing.copyWith(role: _role!),
      userId: widget.userId,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    widget.onSaved?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.roleRequired, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _role,
                  hint: Text(l10n.roleLabel),
                  items: [
                    DropdownMenuItem(value: 'athlete', child: Text(l10n.roleAthlete)),
                    DropdownMenuItem(value: 'coach', child: Text(l10n.roleCoach)),
                  ],
                  onChanged: (value) => setState(() => _role = value),
                  decoration: InputDecoration(labelText: l10n.roleLabel),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saving || _role == null ? null : _saveRole,
                  child: Text(_saving ? l10n.busy : l10n.save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StartupSyncedClickerScreen extends StatefulWidget {
  const StartupSyncedClickerScreen({
    super.key,
    this.startupSyncBuilder,
    this.foregroundSyncBuilder,
    this.enableBackgroundTasks = true,
  });

  final Future<void> Function()? startupSyncBuilder;
  final Future<void> Function()? foregroundSyncBuilder;
  final bool enableBackgroundTasks;

  @override
  State<StartupSyncedClickerScreen> createState() =>
      _StartupSyncedClickerScreenState();
}

class _StartupSyncedClickerScreenState
    extends State<StartupSyncedClickerScreen> with WidgetsBindingObserver {
  late final Future<void> _startupSync;
  var _startupFinished = false;
  var _foregroundSyncRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startupSync = (widget.startupSyncBuilder ?? _syncStartupSync)();
    _startupSync.whenComplete(() {
      _startupFinished = true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _retryPendingSyncIfNeeded();
  }

  Future<void> _syncStartupSync() async {
    try {
      final repo = await PrefsRepository.create();
      await CloudSettingsService().syncLocalAndRemote(repo);
      final enabled = await repo.isSyncHistoryEnabled();
      if (!enabled) return;

      await CloudHistoryService().syncLocalAndRemote(repo);
    } catch (e) {
      debugPrint('Startup history sync error: $e');
    }
  }

  Future<void> _retryPendingSyncIfNeeded() async {
    if (!_startupFinished || _foregroundSyncRunning) return;
    _foregroundSyncRunning = true;
    try {
      await (widget.foregroundSyncBuilder ?? _syncPendingSync)();
    } catch (e) {
      debugPrint('Foreground sync error: $e');
    } finally {
      _foregroundSyncRunning = false;
    }
  }

  Future<void> _syncPendingSync() async {
    try {
      final repo = await PrefsRepository.create();
      if (!repo.isSyncPending()) return;

      await CloudSettingsService().syncLocalAndRemote(repo);
      if (await repo.isSyncHistoryEnabled()) {
        await CloudHistoryService().syncLocalAndRemote(repo);
      }
    } catch (e) {
      debugPrint('Foreground pending sync retry error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _startupSync,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            key: AuthGateKeys.loadingScreenKey,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return ClickerScreen(
          key: AuthGateKeys.clickerScreenKey,
          enableBackgroundTasks: widget.enableBackgroundTasks,
        );
      },
    );
  }
}
