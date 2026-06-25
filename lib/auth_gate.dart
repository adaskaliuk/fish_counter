import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_counter/auth_screen.dart';
import 'package:fish_counter/clicker_screen.dart';
import 'package:fish_counter/services/cloud_history_service.dart';
import 'package:fish_counter/services/cloud_settings_service.dart';
import 'package:fish_counter/services/prefs_repository.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == null) {
          return const AuthScreen();
        }

        return const StartupSyncedClickerScreen();
      },
    );
  }
}

class StartupSyncedClickerScreen extends StatefulWidget {
  const StartupSyncedClickerScreen({super.key, this.startupSyncBuilder});

  final Future<void> Function()? startupSyncBuilder;

  @override
  State<StartupSyncedClickerScreen> createState() =>
      _StartupSyncedClickerScreenState();
}

class _StartupSyncedClickerScreenState
    extends State<StartupSyncedClickerScreen> {
  late final Future<void> _startupSync;

  @override
  void initState() {
    super.initState();
    _startupSync = (widget.startupSyncBuilder ?? _syncHistoryIfEnabled)();
  }

  Future<void> _syncHistoryIfEnabled() async {
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _startupSync,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return const ClickerScreen();
      },
    );
  }
}
