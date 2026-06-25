import 'dart:async';
import 'dart:math' as math;

import 'package:battery_plus/battery_plus.dart';
import 'package:fish_counter/constants.dart';
import 'package:fish_counter/controllers/clicker_controller.dart';
import 'package:fish_counter/services/prefs_repository.dart';
import 'package:fish_counter/services/timer_manager.dart';
import 'package:fish_counter/shake_undo_settings.dart';
import 'package:fish_counter/undo_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sensors_plus/sensors_plus.dart';

@immutable
class ClickerState {
  final int counter1;
  final int counter2;
  final int tries;
  final int total;
  final bool isPowerOn;
  final bool isPaused;
  final bool isActionDelay;
  final bool hasHistory;
  final bool isDataHidden;
  final bool isVibeFlash;
  final bool isSessionActive;
  final bool isSyncHistoryEnabled;
  final bool isShakeUndoEnabled;
  final ShakeSensitivity shakeSensitivity;
  final Duration duration;
  final Duration matchInterval;
  final int resetDelay;
  final int vibeInterval;
  final int delayCountdown;
  final String realTime;
  final String currentDate;
  final int batteryLevel;
  final List<Map<String, dynamic>> activityGrid;

  const ClickerState({
    this.counter1 = 0,
    this.counter2 = 0,
    this.tries = 0,
    this.total = 0,
    this.isPowerOn = true,
    this.isPaused = true,
    this.isActionDelay = false,
    this.hasHistory = false,
    this.isDataHidden = false,
    this.isVibeFlash = false,
    this.isSessionActive = false,
    this.isSyncHistoryEnabled = Defaults.defaultSyncHistoryEnabled,
    this.isShakeUndoEnabled = Defaults.defaultShakeUndoEnabled,
    this.shakeSensitivity = ShakeSensitivity.medium,
    this.duration = Duration.zero,
    this.matchInterval = const Duration(
      seconds: Defaults.defaultMatchDurationSeconds,
    ),
    this.resetDelay = Defaults.defaultResetDelaySeconds,
    this.vibeInterval = Defaults.defaultVibeIntervalSeconds,
    this.delayCountdown = 0,
    this.realTime = '--:--:--',
    this.currentDate = '--.--.--',
    this.batteryLevel = 0,
    this.activityGrid = const [],
  });

  ClickerState copyWith({
    int? counter1,
    int? counter2,
    int? tries,
    int? total,
    bool? isPowerOn,
    bool? isPaused,
    bool? isActionDelay,
    bool? hasHistory,
    bool? isDataHidden,
    bool? isVibeFlash,
    bool? isSessionActive,
    bool? isSyncHistoryEnabled,
    bool? isShakeUndoEnabled,
    ShakeSensitivity? shakeSensitivity,
    Duration? duration,
    Duration? matchInterval,
    int? resetDelay,
    int? vibeInterval,
    int? delayCountdown,
    String? realTime,
    String? currentDate,
    int? batteryLevel,
    List<Map<String, dynamic>>? activityGrid,
  }) {
    return ClickerState(
      counter1: counter1 ?? this.counter1,
      counter2: counter2 ?? this.counter2,
      tries: tries ?? this.tries,
      total: total ?? this.total,
      isPowerOn: isPowerOn ?? this.isPowerOn,
      isPaused: isPaused ?? this.isPaused,
      isActionDelay: isActionDelay ?? this.isActionDelay,
      hasHistory: hasHistory ?? this.hasHistory,
      isDataHidden: isDataHidden ?? this.isDataHidden,
      isVibeFlash: isVibeFlash ?? this.isVibeFlash,
      isSessionActive: isSessionActive ?? this.isSessionActive,
      isSyncHistoryEnabled: isSyncHistoryEnabled ?? this.isSyncHistoryEnabled,
      isShakeUndoEnabled: isShakeUndoEnabled ?? this.isShakeUndoEnabled,
      shakeSensitivity: shakeSensitivity ?? this.shakeSensitivity,
      duration: duration ?? this.duration,
      matchInterval: matchInterval ?? this.matchInterval,
      resetDelay: resetDelay ?? this.resetDelay,
      vibeInterval: vibeInterval ?? this.vibeInterval,
      delayCountdown: delayCountdown ?? this.delayCountdown,
      realTime: realTime ?? this.realTime,
      currentDate: currentDate ?? this.currentDate,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      activityGrid: activityGrid ?? this.activityGrid,
    );
  }
}

class ClickerProvider extends ChangeNotifier {
  final PrefsRepository _prefs;
  final Battery _battery;
  final TimerManager _timerManager;

  ClickerState _state = const ClickerState();
  ClickerState get state => _state;

  Timer? _countdownTimer;
  StreamSubscription<AccelerometerEvent>? _shakeSubscription;
  DateTime? _lastShakeUndoAt;

  ClickerProvider({
    required PrefsRepository prefs,
    Battery? battery,
    TimerManager? timerManager,
  })  : _prefs = prefs,
        _battery = battery ?? Battery(),
        _timerManager = timerManager ?? TimerManager();

  Future<void> initialize() async {
    final initialState = await _prefs.loadInitialState();
    _state = _state.copyWith(
      counter1: initialState.counter1,
      counter2: initialState.counter2,
      tries: initialState.tries,
      total: initialState.total,
      isPowerOn: initialState.powerOn,
      isPaused: initialState.paused,
      isSessionActive: initialState.sessionActive,
      isDataHidden: initialState.dataHidden,
      resetDelay: initialState.resetDelay,
      vibeInterval: initialState.vibeInterval,
      matchInterval: Duration(seconds: initialState.matchSeconds),
      isSyncHistoryEnabled: initialState.syncHistoryEnabled,
      isShakeUndoEnabled: initialState.shakeUndoEnabled,
      shakeSensitivity: ShakeSensitivity.fromValue(
        initialState.shakeSensitivity,
      ),
      activityGrid: initialState.activityGrid,
      hasHistory: initialState.historySessions.isNotEmpty,
    );
    notifyListeners();
  }

  void startGlobalTimer() {
    _timerManager.start(const Duration(seconds: 1), () async {
      if (!_state.isPowerOn) return;

      try {
        final now = DateTime.now();
        var level = _state.batteryLevel;
        final shouldPollBattery = _timerManager.shouldPoll;

        if (shouldPollBattery) {
          try {
            level = await _battery.batteryLevel;
          } catch (e) {
            debugPrint('Battery level error: $e');
          }
        }

        var shouldTriggerVibe = false;
        var newMatchInterval = _state.matchInterval;

        if (_state.isSessionActive && _state.matchInterval.inSeconds > 0) {
          newMatchInterval = _state.matchInterval - const Duration(seconds: 1);
        }

        var newDuration = _state.duration;
        if (!_state.isPaused &&
            _state.isSessionActive &&
            !_state.isActionDelay) {
          newDuration = _state.duration + const Duration(seconds: 1);
          shouldTriggerVibe =
              _state.vibeInterval > 0 &&
                  newDuration.inSeconds != 0 &&
                  newDuration.inSeconds % _state.vibeInterval == 0;
        }

        _state = _state.copyWith(
          realTime: DateFormat('HH:mm:ss').format(now),
          currentDate: DateFormat('dd.MM.yy').format(now),
          batteryLevel: level,
          matchInterval: newMatchInterval,
          duration: newDuration,
        );
        notifyListeners();

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
    _state = _state.copyWith(isVibeFlash: true);
    notifyListeners();

    Future.delayed(
      const Duration(milliseconds: Defaults.defaultActivityDelayMs),
      () {
        HapticFeedback.vibrate();
        _state = _state.copyWith(isVibeFlash: false);
        notifyListeners();
      },
    );
  }

  void startShakeListener() {
    _shakeSubscription = accelerometerEventStream().listen(
      (event) {
        final acceleration = math.sqrt(
          event.x * event.x + event.y * event.y + event.z * event.z,
        );

        if (!_state.isShakeUndoEnabled ||
            acceleration < _state.shakeSensitivity.threshold) {
          return;
        }

        final now = DateTime.now();
        final lastShake = _lastShakeUndoAt;
        if (lastShake != null &&
            now.difference(lastShake).inMilliseconds < 1500) {
          return;
        }

        _lastShakeUndoAt = now;
        undoLastAction(fromShake: true);
      },
      onError: (Object error) {
        debugPrint('Shake listener error: $error');
      },
    );
  }

  bool get canUndo => _state.activityGrid.isNotEmpty;

  Future<void> undoLastAction({bool fromShake = false}) async {
    if (!canUndo) {
      if (fromShake) {
        // TODO: Show snackbar via callback
      }
      return;
    }

    HapticFeedback.mediumImpact();
    _countdownTimer?.cancel();

    final result = undoLastAction(
      counter1: _state.counter1,
      counter2: _state.counter2,
      tries: _state.tries,
      isActionDelay: _state.isActionDelay,
      delayCountdown: _state.delayCountdown,
      activityGrid: _state.activityGrid,
    );

    _state = _state.copyWith(
      counter1: result.counter1,
      counter2: result.counter2,
      tries: result.tries,
      total: result.total,
      isActionDelay: result.isActionDelay,
      delayCountdown: result.delayCountdown,
      activityGrid: result.activityGrid,
    );
    notifyListeners();

    await _saveData();
  }

  Future<void> handleIncrement(int type) async {
    if (!ClickerController.canIncrement(
      isPowerOn: _state.isPowerOn,
      isActionDelay: _state.isActionDelay,
      isPaused: _state.isPaused,
      isSessionActive: _state.isSessionActive,
    )) {
      return;
    }

    final sec = _state.duration.inSeconds;

    HapticFeedback.mediumImpact();

    final counters = ClickerController.incrementCounters(
      counter1: _state.counter1,
      counter2: _state.counter2,
      tries: _state.tries,
      type: type,
    );

    final newActivityGrid = List<Map<String, dynamic>>.from(
      _state.activityGrid,
    );
    newActivityGrid.add(
      ClickerController.buildActivityEntry(
        type: type,
        intervalSeconds: sec,
        targetInterval: _state.vibeInterval,
        timestamp: DateFormat('HH:mm:ss').format(DateTime.now()),
      ),
    );

    _state = _state.copyWith(
      counter1: counters.counter1,
      counter2: counters.counter2,
      tries: counters.tries,
      total: counters.total,
      activityGrid: newActivityGrid,
      duration: Duration.zero,
      isActionDelay: true,
      delayCountdown: _state.resetDelay,
    );
    notifyListeners();

    await _saveData();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_state.delayCountdown > 1) {
        _state = _state.copyWith(delayCountdown: _state.delayCountdown - 1);
        notifyListeners();
      } else {
        _state = _state.copyWith(
          isActionDelay: false,
          delayCountdown: 0,
        );
        notifyListeners();
        t.cancel();
      }
    });
  }

  Future<void> togglePause() async {
    final pauseState = ClickerController.togglePause(
      isSessionActive: _state.isSessionActive,
      isPaused: _state.isPaused,
    );

    var newActivityGrid = _state.activityGrid;
    if (pauseState.shouldAddPauseMarker) {
      newActivityGrid = List<Map<String, dynamic>>.from(_state.activityGrid);
      newActivityGrid.add(
        ClickerController.buildPauseEntry(
          timestamp: DateFormat('HH:mm:ss').format(DateTime.now()),
        ),
      );
    }

    _state = _state.copyWith(
      isSessionActive: pauseState.isSessionActive,
      isPaused: pauseState.isPaused,
      isDataHidden: pauseState.isDataHidden,
      duration: pauseState.shouldResetDuration ? Duration.zero : _state.duration,
      activityGrid: newActivityGrid,
    );
    notifyListeners();

    await _saveData();
  }

  Future<void> turnPowerOn() async {
    final powerState = ClickerController.turnPowerOn();
    _state = _state.copyWith(
      isPowerOn: powerState.isPowerOn,
      isPaused: powerState.isPaused,
      isSessionActive: powerState.isSessionActive,
      isDataHidden: powerState.isDataHidden,
      isActionDelay: powerState.isActionDelay,
      delayCountdown: powerState.delayCountdown,
      duration: powerState.duration,
    );
    notifyListeners();
    await _saveData();
  }

  Future<void> turnPowerOff() async {
    final powerState = ClickerController.turnPowerOffWithoutSaving();
    _state = _state.copyWith(
      isPowerOn: powerState.isPowerOn,
      isPaused: powerState.isPaused,
      isSessionActive: powerState.isSessionActive,
      isDataHidden: powerState.isDataHidden,
      isActionDelay: powerState.isActionDelay,
      delayCountdown: powerState.delayCountdown,
      duration: powerState.duration,
    );
    notifyListeners();
    await _saveData();
  }

  Future<void> resetAfterSessionSaved() async {
    final powerState = ClickerController.resetAfterSessionSaved();
    _state = _state.copyWith(
      isPowerOn: powerState.isPowerOn,
      isPaused: powerState.isPaused,
      isSessionActive: powerState.isSessionActive,
      isDataHidden: powerState.isDataHidden,
      isActionDelay: powerState.isActionDelay,
      delayCountdown: powerState.delayCountdown,
      duration: powerState.duration,
      counter1: powerState.shouldResetCounters ? 0 : _state.counter1,
      counter2: powerState.shouldResetCounters ? 0 : _state.counter2,
      tries: powerState.shouldResetCounters ? 0 : _state.tries,
      total: powerState.shouldResetCounters ? 0 : _state.total,
      activityGrid: powerState.shouldClearActivity ? [] : _state.activityGrid,
      hasHistory: powerState.hasHistory,
      matchInterval: powerState.matchInterval,
    );
    notifyListeners();
    await _saveData();
  }

  Future<void> _saveData() async {
    await _prefs.saveClickerState(
      c1: _state.counter1,
      c2: _state.counter2,
      tries: _state.tries,
      total: _state.total,
      powerOn: _state.isPowerOn,
      paused: _state.isPaused,
      sessionActive: _state.isSessionActive,
      dataHidden: _state.isDataHidden,
      resetDelay: _state.resetDelay,
      vibeInterval: _state.vibeInterval,
      matchSeconds: _state.matchInterval.inSeconds,
      syncHistoryEnabled: _state.isSyncHistoryEnabled,
      shakeUndoEnabled: _state.isShakeUndoEnabled,
      shakeSensitivity: _state.shakeSensitivity.value,
      activityGrid: _state.activityGrid,
    );
  }

  @override
  void dispose() {
    _timerManager.dispose();
    _countdownTimer?.cancel();
    _shakeSubscription?.cancel();
    super.dispose();
  }
}
