// ==========================================
// MAIN SCREEN
// ==========================================
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_counter/models/athlete_profile.dart';
import 'package:fish_counter/models/fishing_presets.dart';
import 'package:fish_counter/widgets/sync_badge_button.dart';
import 'package:fish_counter/widgets/sync_status_banner.dart';
import 'package:fish_counter/history_screen.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/providers/clicker_provider.dart';
import 'package:fish_counter/services/cloud_history_service.dart';
import 'package:fish_counter/services/cloud_settings_service.dart';
import 'package:fish_counter/services/prefs_repository.dart';
import 'package:fish_counter/shake_undo_settings.dart';
import 'package:fish_counter/utils/type_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

part 'clicker_screen_dialogs.dart';

abstract final class ClickerScreenKeys {
  static const c1ValueKey = ValueKey('clicker_c1_value');
  static const totalValueKey = ValueKey('clicker_total_value');
  static const c2ValueKey = ValueKey('clicker_c2_value');
  static const c1ButtonKey = ValueKey('clicker_c1_button');
  static const c2ButtonKey = ValueKey('clicker_c2_button');
  static const tryButtonKey = ValueKey('clicker_try_button');
  static const startPauseButtonKey = ValueKey('clicker_start_pause_button');
  static const undoButtonKey = ValueKey('clicker_undo_button');
  static const settingsButtonKey = ValueKey('clicker_settings_button');
  static const historyButtonKey = ValueKey('clicker_history_button');
  static const syncBadgeButtonKey = ValueKey('clicker_sync_badge_button');
  static const powerButtonKey = ValueKey('clicker_power_button');
  static const signOutButtonKey = ValueKey('clicker_sign_out_button');
}

// ==========================================
// MAIN WIDGET
// ==========================================
class ClickerScreen extends StatefulWidget {
  const ClickerScreen({
    super.key,
    this.enableBackgroundTasks = true,
    this.initialSyncPending,
  });

  final bool enableBackgroundTasks;
  final bool? initialSyncPending;

  @override
  State<ClickerScreen> createState() => _ClickerScreenState();
}

class _ClickerScreenState extends State<ClickerScreen> {
  final ScrollController _gridScrollController = ScrollController();
  late final Future<ClickerProvider> _providerFuture;
  PrefsRepository? _prefsRepository;
  ClickerProvider? _provider;
  bool _syncPending = false;
  bool _isRetryingSync = false;
  String _syncError = '';

  @override
  void initState() {
    super.initState();
    _syncPending = widget.initialSyncPending ?? false;
    _providerFuture = _loadProvider();
  }

  Future<ClickerProvider> _loadProvider() async {
    final repo = await PrefsRepository.create();
    _prefsRepository = repo;
    _syncPending = widget.initialSyncPending ?? repo.isSyncPending();
    _syncError = repo.getSyncLastError();
    final provider = ClickerProvider(prefs: repo);
    await provider.initialize();
    if (widget.enableBackgroundTasks) {
      provider.startGlobalTimer();
      provider.startShakeListener();
    }
    if (!mounted) {
      provider.dispose();
      return provider;
    }
    setState(() => _provider = provider);
    return provider;
  }

  @override
  void dispose() {
    _provider?.dispose();
    _provider = null;
    _gridScrollController.dispose();
    super.dispose();
  }

  Future<void> _retrySyncNow() async {
    final repo = _prefsRepository ?? await PrefsRepository.create();
    if (!repo.isSyncPending()) {
      if (mounted) {
        setState(() => _syncPending = false);
      }
      return;
    }

    if (mounted) {
      setState(() => _isRetryingSync = true);
    }

    try {
      await CloudSettingsService().syncLocalAndRemote(repo);
      if (await repo.isSyncHistoryEnabled()) {
        await CloudHistoryService().syncLocalAndRemote(repo);
      }
    } catch (e) {
      debugPrint('Manual sync retry error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _syncPending = repo.isSyncPending();
          _syncError = repo.getSyncLastError();
          _isRetryingSync = false;
        });
      }
    }
  }

  Future<void> _refreshSyncState(PrefsRepository repo) async {
    if (!mounted) return;
    setState(() {
      _syncPending = repo.isSyncPending();
      _syncError = repo.getSyncLastError();
    });
  }

  Future<ClickerProvider> _ensureProvider() async {
    final provider = _provider;
    if (provider != null) return provider;
    return _providerFuture;
  }

  ClickerProvider get _providerOrThrow {
    final provider = _provider;
    if (provider == null) {
      throw StateError('ClickerProvider not ready');
    }
    return provider;
  }

  // ==========================================
  // UI: LCD DISPLAY
  // ==========================================
  Widget _buildLCD(BuildContext context) {
    final state = context.watch<ClickerProvider>().state;
    String f(int n) => n.toString().padLeft(2, '0');

    String formatMatch(Duration d) {
      final days = d.inDays > 0 ? '${d.inDays}d ' : '';
      return '$days${f(d.inHours % 24)}:${f(d.inMinutes % 60)}:${f(d.inSeconds % 60)}';
    }

    return Expanded(
      flex: 5,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: !state.isPowerOn
              ? const Color(0xFF1A1C14)
              : (state.isVibeFlash
                    ? const Color(0xFFDAE0B0)
                    : const Color(0xFFC0C7B0)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black87, width: 3),
        ),
        child: state.isPowerOn
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          state.currentDate,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          state.realTime,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          '${state.batteryLevel}%',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _lcdStat(
                          'C1',
                          state.isDataHidden ? null : state.counter1,
                          valueKey: ClickerScreenKeys.c1ValueKey,
                        ),
                        _lcdStat(
                          'TOTAL',
                          state.isDataHidden ? null : state.total,
                          isBold: true,
                          valueKey: ClickerScreenKeys.totalValueKey,
                        ),
                        _lcdStat(
                          'C2',
                          state.isDataHidden ? null : state.counter2,
                          valueKey: ClickerScreenKeys.c2ValueKey,
                        ),
                      ],
                    ),
                    const Divider(color: Colors.black, thickness: 1, height: 8),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (state.isActionDelay)
                            Positioned(
                              top: 2,
                              child: Text(
                                '${AppLocalizations.of(context).busy} ${f(state.delayCountdown)}s',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${f(state.duration.inHours)}:${f(state.duration.inMinutes % 60)}:${f(state.duration.inSeconds % 60)}',
                              style: TextStyle(
                                color: state.isPaused
                                    ? Colors.black26
                                    : (state.isActionDelay
                                          ? Colors.black38
                                          : Colors.black),
                                fontSize: 60,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.black, thickness: 1, height: 8),
                    SizedBox(height: 70, child: _buildGrid(context)),
                    const Divider(color: Colors.black, thickness: 1, height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatMatch(state.matchInterval),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox(),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final state = context.watch<ClickerProvider>().state;
    return GridView.builder(
      controller: _gridScrollController,
      scrollDirection: Axis.horizontal,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 4,
      ),
      itemCount: state.activityGrid.length,
      itemBuilder: (context, index) {
        final e = state.activityGrid[index];
        final type = _safeInt(e['type']);
        final IconData icon;

        if (type == 0) {
          icon = Icons.close;
        } else if (type == 1) {
          icon = Icons.stop;
        } else if (type == 2) {
          icon = Icons.change_history;
        } else {
          icon = Icons.circle;
        }

        return Icon(icon, size: 20, color: _getStatusColor(e['status']));
      },
    );
  }

  Color _getStatusColor(dynamic s) {
    switch (s?.toString()) {
      case 'green':
        return Colors.green.shade900;
      case 'red':
        return Colors.red.shade900;
      case 'grey':
        return Colors.grey.shade700;
      default:
        return Colors.orange.shade900;
    }
  }

  Widget _lcdStat(
    String label,
    int? value, {
    bool isBold = false,
    Key? valueKey,
  }) => Column(
    children: [
      Text(label, style: const TextStyle(color: Colors.black, fontSize: 9)),
      Text(
        key: valueKey,
        value == null ? '--' : '$value',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
        ),
      ),
    ],
  );

  // ==========================================
  // UI: CONTROLS
  // ==========================================
  Widget _buildControls(BuildContext context) {
    final state = context.watch<ClickerProvider>().state;
    final l10n = AppLocalizations.of(context);
    const double mainSize = 75.0;

    return Expanded(
      flex: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _btn(
                'C 1',
                () => context.read<ClickerProvider>().handleIncrement(1),
                mainSize,
                buttonKey: ClickerScreenKeys.c1ButtonKey,
                isActionBtn: true,
                state: state,
              ),
              _btn(
                l10n.tryButton,
                () => context.read<ClickerProvider>().handleIncrement(3),
                55,
                buttonKey: ClickerScreenKeys.tryButtonKey,
                isSmall: true,
                isActionBtn: true,
                state: state,
              ),
              _btn(
                'C 2',
                () => context.read<ClickerProvider>().handleIncrement(2),
                mainSize,
                buttonKey: ClickerScreenKeys.c2ButtonKey,
                isActionBtn: true,
                state: state,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _btn(
                state.isPaused ? l10n.start : l10n.pause,
                () => context.read<ClickerProvider>().togglePause(),
                mainSize,
                buttonKey: ClickerScreenKeys.startPauseButtonKey,
                isAccent: true,
                state: state,
              ),
              _btn(
                l10n.undo,
                () => context.read<ClickerProvider>().undoLastAction(),
                55,
                buttonKey: ClickerScreenKeys.undoButtonKey,
                isSmall: true,
                isUndoBtn: true,
                enabledWhenPowerOff: true,
                state: state,
              ),
              _btn(
                l10n.settings,
                _showSettings,
                mainSize,
                buttonKey: ClickerScreenKeys.settingsButtonKey,
                isSmall: true,
                enabledWhenPowerOff: true,
                state: state,
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: state.hasHistory
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: IconButton(
                            key: ClickerScreenKeys.historyButtonKey,
                            icon: const Icon(
                              Icons.history,
                              size: 34,
                              color: Colors.white54,
                            ),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) =>
                                    HistoryScreen(onHistoryUpdate: () {
                                      context.read<ClickerProvider>().initialize();
                                    }),
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    key: ClickerScreenKeys.powerButtonKey,
                    onTap: _handlePower,
                    child: CircleAvatar(
                      backgroundColor: state.isPowerOn
                          ? Colors.red.shade900
                          : Colors.green.shade900,
                      radius: 26,
                      child: const Icon(
                        Icons.power_settings_new,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_syncPending || _isRetryingSync)
                          SyncBadgeButton(
                            key: ClickerScreenKeys.syncBadgeButtonKey,
                            tooltip: AppLocalizations.of(context).syncNow,
                            isLoading: _isRetryingSync,
                            onPressed: _retrySyncNow,
                          ),
                        IconButton(
                          key: ClickerScreenKeys.signOutButtonKey,
                          tooltip: AppLocalizations.of(context).signOut,
                          icon: const Icon(
                            Icons.account_circle,
                            size: 34,
                            color: Colors.white54,
                          ),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            try {
                              await GoogleSignIn.instance.signOut();
                            } catch (e) {
                              debugPrint('Google sign-out error: $e');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShell(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.black, width: 4),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.hourglass_top, color: Colors.white54, size: 36),
                ),
                if (_syncError.isNotEmpty)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SyncStatusBanner(
                        title: l10n.cloudSyncFailed,
                        message: _syncError,
                      ),
                    ),
                  ),
                if (_syncPending)
                  Align(
                    alignment: Alignment.topRight,
                    child: SyncBadgeButton(
                      key: ClickerScreenKeys.syncBadgeButtonKey,
                      tooltip: l10n.syncNow,
                      onPressed: _retrySyncNow,
                    ),
                  ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: GestureDetector(
                      key: ClickerScreenKeys.settingsButtonKey,
                      onTap: _showSettings,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 26,
                        child: Text(
                          l10n.settings,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _btn(
    String label,
    VoidCallback onTap,
    double size, {
    Key? buttonKey,
    bool isSmall = false,
    bool isAccent = false,
    bool isActionBtn = false,
    bool isUndoBtn = false,
    bool enabledWhenPowerOff = false,
    required ClickerState state,
  }) {
    final isDisabled =
        (!state.isPowerOn && !enabledWhenPowerOff) ||
        (isActionBtn && (!state.isSessionActive || state.isPaused || state.isActionDelay)) ||
        (isUndoBtn && !state.activityGrid.isNotEmpty);

    return GestureDetector(
      key: buttonKey,
      onTap: isDisabled ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isDisabled ? 0.12 : 1.0,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isAccent
                ? (state.isPaused ? Colors.green.shade100 : Colors.orange.shade100)
                : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(width: 3, color: Colors.black),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: isSmall ? 10 : 13,
            ),
          ),
        ),
      ),
    );
  }

  void _showSettings() => _showSettingsDialog(this);

  Future<void> _handlePower() async {
    final provider = _providerOrThrow;
    final state = provider.state;
    
    if (state.isPowerOn) {
      if (state.isSessionActive ||
          state.activityGrid.isNotEmpty ||
          state.counter1 > 0 ||
          state.counter2 > 0 ||
          state.tries > 0 ||
          state.total > 0) {
        await provider.finishSessionAndPowerOff();
      } else {
        await provider.turnPowerOff();
      }
    } else {
      await provider.turnPowerOn();
    }
  }

  // ==========================================
  ClickerState get _clickerStateOrDefault =>
      _provider?.state ?? const ClickerState();

  bool get isPowerOn => _clickerStateOrDefault.isPowerOn;
  int get resetDelay => _clickerStateOrDefault.resetDelay;
  int get vibeInterval => _clickerStateOrDefault.vibeInterval;
  Duration get matchInterval => _clickerStateOrDefault.matchInterval;
  bool get isSyncHistoryEnabled => _clickerStateOrDefault.isSyncHistoryEnabled;
  bool get isShakeUndoEnabled => _clickerStateOrDefault.isShakeUndoEnabled;
  ShakeSensitivity get shakeSensitivity => _clickerStateOrDefault.shakeSensitivity;
  int get counter1 => _clickerStateOrDefault.counter1;
  int get counter2 => _clickerStateOrDefault.counter2;
  int get tries => _clickerStateOrDefault.tries;
  int get total => _clickerStateOrDefault.total;
  bool get isSessionActive => _clickerStateOrDefault.isSessionActive;
  bool get isPaused => _clickerStateOrDefault.isPaused;
  bool get isActionDelay => _clickerStateOrDefault.isActionDelay;
  bool get isDataHidden => _clickerStateOrDefault.isDataHidden;
  List<Map<String, dynamic>> get activityGrid =>
      _clickerStateOrDefault.activityGrid;

  void _applySettings({
    required int resetDelay,
    required int vibeInterval,
    required Duration matchInterval,
    required bool syncHistoryEnabled,
    required bool shakeUndoEnabled,
    required ShakeSensitivity shakeSensitivity,
  }) {
    _providerOrThrow.applySettings(
      resetDelay: resetDelay,
      vibeInterval: vibeInterval,
      matchInterval: matchInterval,
      syncHistoryEnabled: syncHistoryEnabled,
      shakeUndoEnabled: shakeUndoEnabled,
      shakeSensitivity: shakeSensitivity,
    );
  }

  Future<void> _saveData() => _providerOrThrow.saveData();

  // UTILS
  // ==========================================
  static int _safeInt(dynamic value, {int defaultValue = 0}) {
    return TypeUtils.safeInt(value, defaultValue: defaultValue);
  }

  @override
  Widget build(BuildContext context) {
    final provider = _provider;
    if (provider == null) {
      return _buildLoadingShell(context);
    }

    return ChangeNotifierProvider.value(
      value: provider,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: _syncError.isNotEmpty ? 72 : 0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 420),
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF333333),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.black, width: 4),
                    ),
                    child: Column(
                      children: [
                        Builder(builder: _buildLCD),
                        const SizedBox(height: 12),
                        Builder(builder: _buildControls),
                      ],
                    ),
                  ),
                ),
                if (_syncError.isNotEmpty)
                  Positioned(
                    top: 0,
                    child: SizedBox(
                      width: 420,
                      child: SyncStatusBanner(
                        title: AppLocalizations.of(context).cloudSyncFailed,
                        message: _syncError,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
