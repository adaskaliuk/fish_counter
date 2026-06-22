// ==========================================
// MAIN SCREEN
// ==========================================
import 'dart:async';
import 'dart:math' as math;

import 'package:battery_plus/battery_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_counter/constants.dart';
import 'package:fish_counter/controllers/clicker_controller.dart';
import 'package:fish_counter/history_screen.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/athlete_profile.dart';
import 'package:fish_counter/models/weather_snapshot.dart';
import 'package:fish_counter/services/cloud_history_service.dart';
import 'package:fish_counter/services/cloud_settings_service.dart';
import 'package:fish_counter/services/prefs_repository.dart';
import 'package:fish_counter/services/weather_service.dart';
import 'package:fish_counter/shake_undo_settings.dart';
import 'package:fish_counter/undo_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:sensors_plus/sensors_plus.dart';

part 'clicker_screen_dialogs.dart';

// ==========================================
// MAIN WIDGET
// ==========================================
class ClickerScreen extends StatefulWidget {
  const ClickerScreen({super.key});

  @override
  State<ClickerScreen> createState() => _ClickerScreenState();
}

class _ClickerScreenState extends State<ClickerScreen> {
  // Counters
  int counter1 = 0;
  int counter2 = 0;
  int tries = 0;
  int total = 0;

  // State flags
  bool isPowerOn = true;
  bool isPaused = true;
  bool isActionDelay = false;
  bool hasHistory = false;
  bool isDataHidden = false;
  bool isVibeFlash = false;
  bool isSessionActive = false;
  bool isSyncHistoryEnabled = Defaults.defaultSyncHistoryEnabled;
  bool isShakeUndoEnabled = Defaults.defaultShakeUndoEnabled;
  ShakeSensitivity shakeSensitivity = ShakeSensitivity.medium;

  // Timers
  Duration duration = Duration.zero;
  Duration matchInterval = const Duration(
    seconds: Defaults.defaultMatchDurationSeconds,
  );
  int resetDelay = Defaults.defaultResetDelaySeconds;
  int vibeInterval = Defaults.defaultVibeIntervalSeconds;
  int delayCountdown = 0;

  // Display
  String realTime = '--:--:--';
  String currentDate = '--.--.--';
  int batteryLevel = 0;

  // Services
  final Battery _battery = Battery();
  Timer? _timer;
  Timer? _countdownTimer;
  StreamSubscription<AccelerometerEvent>? _shakeSubscription;
  int _batteryPollTick = 0;
  DateTime? _lastShakeUndoAt;

  // Activity grid
  List<Map<String, dynamic>> activityGrid = [];
  final ScrollController _gridScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _startGlobalTimer();
    _startShakeListener();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    _shakeSubscription?.cancel();
    _gridScrollController.dispose();
    super.dispose();
  }

  void _startGlobalTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted || !isPowerOn) return;

      try {
        final now = DateTime.now();
        var level = batteryLevel;
        final shouldPollBattery = _batteryPollTick == 0;
        _batteryPollTick = (_batteryPollTick + 1) % 30;

        if (shouldPollBattery) {
          try {
            level = await _battery.batteryLevel;
          } catch (e) {
            debugPrint('Battery level error: $e');
          }
        }

        if (!mounted) return;

        var shouldTriggerVibe = false;

        setState(() {
          realTime = DateFormat('HH:mm:ss').format(now);
          currentDate = DateFormat('dd.MM.yy').format(now);
          batteryLevel = level;

          if (isSessionActive && matchInterval.inSeconds > 0) {
            matchInterval -= const Duration(seconds: 1);
          }

          if (!isPaused && isSessionActive && !isActionDelay) {
            duration += const Duration(seconds: 1);
            shouldTriggerVibe =
                vibeInterval > 0 &&
                duration.inSeconds != 0 &&
                duration.inSeconds % vibeInterval == 0;
          }
        });

        if (shouldTriggerVibe) {
          _triggerVibeFeedback();
        }
      } catch (e) {
        debugPrint('Timer error: $e');
      }
    });
  }

  void _triggerVibeFeedback() {
    HapticFeedback.vibrate();
    if (!mounted) return;
    setState(() => isVibeFlash = true);

    Future.delayed(
      const Duration(milliseconds: Defaults.defaultActivityDelayMs),
      () {
        if (!mounted) return;
        HapticFeedback.vibrate();
        setState(() => isVibeFlash = false);
      },
    );
  }

  void _startShakeListener() {
    _shakeSubscription = accelerometerEventStream().listen(
      (event) {
        final acceleration = math.sqrt(
          event.x * event.x + event.y * event.y + event.z * event.z,
        );

        if (!isShakeUndoEnabled || acceleration < shakeSensitivity.threshold) {
          return;
        }

        final now = DateTime.now();
        final lastShake = _lastShakeUndoAt;
        if (lastShake != null &&
            now.difference(lastShake).inMilliseconds < 1500) {
          return;
        }

        _lastShakeUndoAt = now;
        _undoLastAction(fromShake: true);
      },
      onError: (Object error) {
        debugPrint('Shake listener error: $error');
      },
    );
  }

  bool get _canUndo => activityGrid.isNotEmpty;

  Future<void> _undoLastAction({bool fromShake = false}) async {
    if (!_canUndo) {
      if (fromShake && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).nothingToUndo)),
        );
      }
      return;
    }

    HapticFeedback.mediumImpact();
    _countdownTimer?.cancel();

    setState(() {
      final result = undoLastAction(
        counter1: counter1,
        counter2: counter2,
        tries: tries,
        isActionDelay: isActionDelay,
        delayCountdown: delayCountdown,
        activityGrid: activityGrid,
      );

      counter1 = result.counter1;
      counter2 = result.counter2;
      tries = result.tries;
      total = result.total;
      isActionDelay = result.isActionDelay;
      delayCountdown = result.delayCountdown;
      activityGrid = result.activityGrid;
    });

    await _saveData();
  }

  void handleIncrement(int type) {
    if (!ClickerController.canIncrement(
      isPowerOn: isPowerOn,
      isActionDelay: isActionDelay,
      isPaused: isPaused,
      isSessionActive: isSessionActive,
    )) {
      return;
    }

    final sec = duration.inSeconds;

    HapticFeedback.mediumImpact();

    setState(() {
      final counters = ClickerController.incrementCounters(
        counter1: counter1,
        counter2: counter2,
        tries: tries,
        type: type,
      );
      counter1 = counters.counter1;
      counter2 = counters.counter2;
      tries = counters.tries;
      total = counters.total;

      activityGrid.add(
        ClickerController.buildActivityEntry(
          type: type,
          intervalSeconds: sec,
          targetInterval: vibeInterval,
          timestamp: DateFormat('HH:mm:ss').format(DateTime.now()),
        ),
      );

      duration = Duration.zero;
      isActionDelay = true;
      delayCountdown = resetDelay;
    });

    _scrollToEnd();
    _saveData();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (delayCountdown > 1) {
          delayCountdown--;
        } else {
          isActionDelay = false;
          delayCountdown = 0;
          t.cancel();
        }
      });
    });
  }

  void togglePause() {
    var shouldScrollToEnd = false;

    setState(() {
      final pauseState = ClickerController.togglePause(
        isSessionActive: isSessionActive,
        isPaused: isPaused,
      );

      isSessionActive = pauseState.isSessionActive;
      isPaused = pauseState.isPaused;
      isDataHidden = pauseState.isDataHidden;

      if (pauseState.shouldResetDuration) {
        duration = Duration.zero;
      }

      if (pauseState.shouldAddPauseMarker) {
        activityGrid.add(
          ClickerController.buildPauseEntry(
            timestamp: DateFormat('HH:mm:ss').format(DateTime.now()),
          ),
        );
        shouldScrollToEnd = true;
      }
    });

    if (shouldScrollToEnd) {
      _scrollToEnd();
    }
    _saveData();
  }

  // ==========================================
  // UI: LCD DISPLAY
  // ==========================================
  Widget _buildLCD() {
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
          color: !isPowerOn
              ? const Color(0xFF1A1C14)
              : (isVibeFlash
                    ? const Color(0xFFDAE0B0)
                    : const Color(0xFFC0C7B0)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black87, width: 3),
        ),
        child: isPowerOn
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
                          currentDate,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          realTime,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          '$batteryLevel%',
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
                        _lcdStat('C1', isDataHidden ? null : counter1),
                        _lcdStat(
                          'TOTAL',
                          isDataHidden ? null : total,
                          isBold: true,
                        ),
                        _lcdStat('C2', isDataHidden ? null : counter2),
                      ],
                    ),
                    const Divider(color: Colors.black, thickness: 1, height: 8),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (isActionDelay)
                            Positioned(
                              top: 2,
                              child: Text(
                                '${AppLocalizations.of(context).busy} ${f(delayCountdown)}s',
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
                              '${f(duration.inHours)}:${f(duration.inMinutes % 60)}:${f(duration.inSeconds % 60)}',
                              style: TextStyle(
                                color: isPaused
                                    ? Colors.black26
                                    : (isActionDelay
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
                    SizedBox(height: 70, child: _buildGrid()),
                    const Divider(color: Colors.black, thickness: 1, height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatMatch(matchInterval),
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

  Widget _buildGrid() {
    return GridView.builder(
      controller: _gridScrollController,
      scrollDirection: Axis.horizontal,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 4,
      ),
      itemCount: activityGrid.length,
      itemBuilder: (context, index) {
        final e = activityGrid[index];
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

  Widget _lcdStat(String label, int? value, {bool isBold = false}) => Column(
    children: [
      Text(label, style: const TextStyle(color: Colors.black, fontSize: 9)),
      Text(
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
  Widget _buildControls() {
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
                () => handleIncrement(1),
                mainSize,
                isActionBtn: true,
              ),
              _btn(
                l10n.tryButton,
                () => handleIncrement(3),
                55,
                isSmall: true,
                isActionBtn: true,
              ),
              _btn(
                'C 2',
                () => handleIncrement(2),
                mainSize,
                isActionBtn: true,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _btn(
                isPaused ? l10n.start : l10n.pause,
                togglePause,
                mainSize,
                isAccent: true,
              ),
              _btn(
                l10n.undo,
                () => _undoLastAction(),
                55,
                isSmall: true,
                isUndoBtn: true,
                enabledWhenPowerOff: true,
              ),
              _btn(
                l10n.settings,
                _showSettings,
                mainSize,
                isSmall: true,
                enabledWhenPowerOff: true,
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: hasHistory
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: IconButton(
                            icon: const Icon(
                              Icons.history,
                              size: 34,
                              color: Colors.white54,
                            ),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) =>
                                    HistoryScreen(onHistoryUpdate: _loadData),
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
                    onTap: _handlePower,
                    child: CircleAvatar(
                      backgroundColor: isPowerOn
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
                    child: IconButton(
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
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _btn(
    String label,
    VoidCallback onTap,
    double size, {
    bool isSmall = false,
    bool isAccent = false,
    bool isActionBtn = false,
    bool isUndoBtn = false,
    bool enabledWhenPowerOff = false,
  }) {
    final isDisabled =
        (!isPowerOn && !enabledWhenPowerOff) ||
        (isActionBtn && (!isSessionActive || isPaused || isActionDelay)) ||
        (isUndoBtn && !_canUndo);

    return GestureDetector(
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
                ? (isPaused ? Colors.green.shade100 : Colors.orange.shade100)
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

  // ==========================================
  // DATA PERSISTENCE
  // ==========================================
  Future<void> _loadData() async {
    try {
      final state = await PrefsRepository.loadState();
      if (!mounted) return;

      setState(() {
        counter1 = state.c1;
        counter2 = state.c2;
        tries = state.tries;
        total = state.total;
        isPowerOn = state.powerOn;
        isPaused = state.paused;
        isSessionActive = state.sessionActive;
        isDataHidden = state.dataHidden;
        resetDelay = state.resetDelay;
        vibeInterval = state.vibeInterval;
        matchInterval = Duration(seconds: state.matchSeconds);
        isSyncHistoryEnabled = state.syncHistoryEnabled;
        isShakeUndoEnabled = state.shakeUndoEnabled;
        shakeSensitivity = ShakeSensitivity.fromValue(state.shakeSensitivity);
        hasHistory = state.historySessions.isNotEmpty;
        activityGrid = state.rawActivityGrid;

        if (isPaused) {
          isDataHidden = true;
          duration = Duration.zero;
        }
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> _syncLocalHistoryToCloud() async {
    try {
      final repo = await PrefsRepository.create();
      await CloudHistoryService().syncLocalAndRemote(repo);
    } catch (e) {
      debugPrint('Error syncing history: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final repo = await PrefsRepository.create();
      await repo.saveClickerState(
        c1: counter1,
        c2: counter2,
        tries: tries,
        total: total,
        powerOn: isPowerOn,
        paused: isPaused,
        sessionActive: isSessionActive,
        dataHidden: isDataHidden,
        resetDelay: resetDelay,
        vibeInterval: vibeInterval,
        matchSeconds: matchInterval.inSeconds,
        syncHistoryEnabled: isSyncHistoryEnabled,
        shakeUndoEnabled: isShakeUndoEnabled,
        shakeSensitivity: shakeSensitivity.value,
        activityGrid: activityGrid,
      );
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  void _scrollToEnd() {
    Future.delayed(
      const Duration(milliseconds: Defaults.defaultScrollDelayMs),
      () {
        if (mounted && _gridScrollController.hasClients) {
          _gridScrollController.jumpTo(
            _gridScrollController.position.maxScrollExtent,
          );
        }
      },
    );
  }

  Future<void> _handlePower() => _handlePowerPress(this);

  void _applyPowerState(ClickerPowerState powerState) {
    setState(() {
      if (powerState.shouldResetCounters) {
        counter1 = 0;
        counter2 = 0;
        tries = 0;
        total = 0;
      }

      if (powerState.shouldClearActivity) {
        activityGrid = [];
      }

      isPowerOn = powerState.isPowerOn;
      isPaused = powerState.isPaused;
      isSessionActive = powerState.isSessionActive;
      isDataHidden = powerState.isDataHidden;
      isActionDelay = powerState.isActionDelay;
      delayCountdown = powerState.delayCountdown;
      duration = powerState.duration;
      hasHistory = hasHistory || powerState.hasHistory;

      final updatedMatchInterval = powerState.matchInterval;
      if (updatedMatchInterval != null) {
        matchInterval = updatedMatchInterval;
      }
    });
  }

  void _applySettings({
    required int resetDelay,
    required int vibeInterval,
    required Duration matchInterval,
    required bool syncHistoryEnabled,
    required bool shakeUndoEnabled,
    required ShakeSensitivity shakeSensitivity,
  }) {
    setState(() {
      this.resetDelay = resetDelay;
      this.vibeInterval = vibeInterval;
      this.matchInterval = matchInterval;
      isSyncHistoryEnabled = syncHistoryEnabled;
      isShakeUndoEnabled = shakeUndoEnabled;
      this.shakeSensitivity = shakeSensitivity;
    });
  }

  // ==========================================
  // UTILS
  // ==========================================
  static int _safeInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? defaultValue;
  }

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              children: [
                _buildLCD(),
                const SizedBox(height: 12),
                _buildControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
