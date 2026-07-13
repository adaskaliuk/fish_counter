import 'dart:async';
import 'dart:math' as math;

import 'package:battery_plus/battery_plus.dart';
import 'package:fish_counter/constants.dart';
import 'package:fish_counter/controllers/clicker_controller.dart';
import 'package:fish_counter/models/weather_snapshot.dart';
import 'package:fish_counter/services/weather_service.dart';
import 'package:fish_counter/services/prefs_repository.dart';
import 'package:fish_counter/services/cloud_history_service.dart';
import 'package:fish_counter/services/timer_manager.dart';
import 'package:fish_counter/shake_undo_settings.dart';
import 'package:fish_counter/undo_manager.dart' as undo;
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
  final List<WeatherSnapshot> weatherSnapshots;

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
    this.weatherSnapshots = const [],
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
    List<WeatherSnapshot>? weatherSnapshots,
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
      weatherSnapshots: weatherSnapshots ?? this.weatherSnapshots,
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
  DateTime? _lastWeatherCaptureAt;
  var _weatherCaptureInFlight = false;
  Future<void>? _weatherCaptureFuture;
  final SessionWeatherService _weatherService = SessionWeatherService();

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
      counter1: initialState.c1,
      counter2: initialState.c2,
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
      activityGrid: initialState.rawActivityGrid,
      weatherSnapshots: initialState.weatherSnapshots,
      hasHistory: initialState.historySessions.isNotEmpty,
    );
    if (initialState.weatherSnapshots.isNotEmpty) {
      _lastWeatherCaptureAt = DateTime.tryParse(
        initialState.weatherSnapshots.last.fetchedAt,
      );
    }
    notifyListeners();
  }

  void startGlobalTimer() {
    _timerManager.start(const Duration(seconds: 1), () async {
      if (!_state.isPowerOn) return;

      try {
        final now = DateTime.now();
        final shouldPollBattery = _timerManager.shouldPoll;

        var shouldTriggerVibe = false;
        var newMatchInterval = _state.matchInterval;
        var sessionEnded = false;

        if (_state.isSessionActive && _state.matchInterval.inSeconds > 0) {
          final next = _state.matchInterval - const Duration(seconds: 1);
          sessionEnded = next.inSeconds <= 0;
          newMatchInterval = sessionEnded ? Duration.zero : next;
        }

        var newDuration = _state.duration;
        if (!sessionEnded &&
            !_state.isPaused &&
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
          matchInterval: newMatchInterval,
          duration: newDuration,
          isSessionActive: sessionEnded ? false : null,
          isPaused: sessionEnded ? true : null,
          isActionDelay: sessionEnded ? false : null,
          delayCountdown: sessionEnded ? 0 : null,
        );
        notifyListeners();

        if (shouldTriggerVibe) {
          _triggerVibeFeedback();
        }

        if (shouldPollBattery) {
          try {
            _state = _state.copyWith(batteryLevel: await _battery.batteryLevel);
            notifyListeners();
          } catch (e) {
            debugPrint('Battery level error: $e');
          }
        }

        await _maybeCaptureWeatherSample(now, force: sessionEnded);
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

    final result = undo.undoLastAction(
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
    if (_state.matchInterval <= Duration.zero) return;
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
    final wasSessionActive = _state.isSessionActive;
    final pauseState = ClickerController.togglePause(
      isSessionActive: _state.isSessionActive,
      isPaused: _state.isPaused,
    );

    var newActivityGrid = _state.activityGrid;
    var newCounter1 = _state.counter1;
    var newCounter2 = _state.counter2;
    var newTries = _state.tries;
    var newTotal = _state.total;
    // ponytail: keep elapsed duration across pause so save retains session time.
    var newDuration = _state.duration;
    var newMatchInterval = _state.matchInterval;
    var newWeatherSnapshots = _state.weatherSnapshots;

    final isStartingFresh = !pauseState.isPaused && !wasSessionActive;
    if (isStartingFresh) {
      _countdownTimer?.cancel();
      newActivityGrid = [];
      newWeatherSnapshots = [];
      newCounter1 = 0;
      newCounter2 = 0;
      newTries = 0;
      newTotal = 0;
      newDuration = Duration.zero;
      newMatchInterval = _state.matchInterval;
    }

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
      duration: newDuration,
      activityGrid: newActivityGrid,
      counter1: newCounter1,
      counter2: newCounter2,
      tries: newTries,
      total: newTotal,
      matchInterval: newMatchInterval,
      weatherSnapshots: newWeatherSnapshots,
      isActionDelay: isStartingFresh ? false : _state.isActionDelay,
      delayCountdown: isStartingFresh ? 0 : _state.delayCountdown,
    );
    notifyListeners();

    if (isStartingFresh) {
      await _maybeCaptureWeatherSample(DateTime.now(), force: true);
    }

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

  bool get _shouldSaveSessionOnPowerOff {
    return _state.isSessionActive ||
        _state.activityGrid.isNotEmpty ||
        _state.counter1 > 0 ||
        _state.counter2 > 0 ||
        _state.tries > 0 ||
        _state.total > 0;
  }

  Future<void> finishSessionAndPowerOff() async {
    await _maybeCaptureWeatherSample(DateTime.now(), force: true);
    final shouldSave = _shouldSaveSessionOnPowerOff;
    if (shouldSave) {
      final settings = _prefs.loadAppSettings();
      final now = DateTime.now();
      final session = ClickerController.buildSession(
        id: now.millisecondsSinceEpoch.toString(),
        name: 'Session',
        date: DateFormat('dd.MM.yy HH:mm').format(now),
        counter1: _state.counter1,
        counter2: _state.counter2,
        tries: _state.tries,
        total: _state.total,
        matchInterval: _state.duration,
        activityGrid: _state.activityGrid,
        weatherHistory: _state.weatherSnapshots,
        athleteName: settings.athleteProfile.athleteName,
        coachName: settings.athleteProfile.coachName,
        venue: settings.athleteProfile.defaultVenue,
        sectorPeg: settings.athleteProfile.defaultSectorPeg,
        trainingType: settings.athleteProfile.defaultTrainingType,
        fishingMethod: settings.athleteProfile.defaultFishingMethod,
        targetPace: settings.athleteProfile.defaultTargetPace,
      );

      await _prefs.addHistorySession(session);
      if (await _prefs.isSyncHistoryEnabled()) {
        try {
          await CloudHistoryService().uploadSession(session);
        } catch (e) {
          debugPrint('Cloud history upload error: $e');
        }
      }
    }

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
      hasHistory: powerState.hasHistory || shouldSave,
      matchInterval: powerState.matchInterval,
      weatherSnapshots: [],
    );
    notifyListeners();
    await _saveData();
  }

  void applyPowerState(ClickerPowerState powerState) {
    _state = _state.copyWith(
      isPowerOn: powerState.isPowerOn,
      isPaused: powerState.isPaused,
      isSessionActive: powerState.isSessionActive,
      isDataHidden: powerState.isDataHidden,
      isActionDelay: powerState.isActionDelay,
      delayCountdown: powerState.delayCountdown,
      duration: powerState.duration,
      resetDelay: powerState.matchInterval == null ? _state.resetDelay : _state.resetDelay,
      matchInterval: powerState.matchInterval ?? _state.matchInterval,
      counter1: powerState.shouldResetCounters ? 0 : _state.counter1,
      counter2: powerState.shouldResetCounters ? 0 : _state.counter2,
      tries: powerState.shouldResetCounters ? 0 : _state.tries,
      total: powerState.shouldResetCounters ? 0 : _state.total,
      activityGrid: powerState.shouldClearActivity ? [] : _state.activityGrid,
      hasHistory: powerState.hasHistory,
    );
    notifyListeners();
  }

  void applySettings({
    required int resetDelay,
    required int vibeInterval,
    required Duration matchInterval,
    required bool syncHistoryEnabled,
    required bool shakeUndoEnabled,
    required ShakeSensitivity shakeSensitivity,
  }) {
    _state = _state.copyWith(
      resetDelay: resetDelay,
      vibeInterval: vibeInterval,
      matchInterval: matchInterval,
      isSyncHistoryEnabled: syncHistoryEnabled,
      isShakeUndoEnabled: shakeUndoEnabled,
      shakeSensitivity: shakeSensitivity,
    );
    notifyListeners();
  }

  Future<void> saveData() => _saveData();

  Future<void> _maybeCaptureWeatherSample(
    DateTime now, {
    bool force = false,
  }) async {
    if (SessionWeatherService.apiKey.isEmpty) return;
    if (_weatherCaptureInFlight) {
      if (force) await _weatherCaptureFuture;
      return;
    }
    if (!force) {
      if (!_state.isPowerOn || !_state.isSessionActive || _state.isPaused) {
        return;
      }
      final lastCapture = _lastWeatherCaptureAt;
      if (lastCapture != null && now.difference(lastCapture) < const Duration(minutes: 15)) {
        return;
      }
    }

    _weatherCaptureInFlight = true;
    _weatherCaptureFuture = () async {
      try {
        _lastWeatherCaptureAt = now;
        final snapshot = await _weatherService.fetchCurrentWeather();
        _state = _state.copyWith(
          weatherSnapshots: [..._state.weatherSnapshots, snapshot],
        );
        notifyListeners();
      } catch (e) {
        debugPrint('Weather capture error: $e');
      } finally {
        _weatherCaptureInFlight = false;
      }
    }();
    await _weatherCaptureFuture;
  }

  void cancelCountdown() {
    _countdownTimer?.cancel();
  }

  Future<void> resetAfterSessionSaved() async {
    final powerState = ClickerController.resetAfterSessionSaved();
    final savedMatchInterval = _state.matchInterval;
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
      matchInterval: savedMatchInterval,
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
      weatherSnapshots: _state.weatherSnapshots.map((snapshot) => snapshot.toJson()).toList(),
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
