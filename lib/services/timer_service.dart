import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service for managing app timers including global timer, countdown timer, and vibe feedback.
class TimerService {
  Timer? _globalTimer;
  Timer? _countdownTimer;
  int _globalTick = 0;
  
  final Duration globalInterval;
  final VoidCallback onGlobalTick;
  final VoidCallback? onVibeTrigger;
  final Duration? vibeInterval;
  final int vibeDelaySeconds;

  TimerService({
    this.globalInterval = const Duration(seconds: 1),
    required this.onGlobalTick,
    this.onVibeTrigger,
    this.vibeInterval,
    this.vibeDelaySeconds = 0,
  });

  void startGlobalTimer() {
    _globalTimer?.cancel();
    _globalTimer = Timer.periodic(globalInterval, (timer) {
      _globalTick++;
      onGlobalTick();
      
      if (onVibeTrigger != null && 
          vibeInterval != null && 
          vibeInterval!.inSeconds > 0 &&
          _globalTick % vibeInterval!.inSeconds == 0) {
        onVibeTrigger!();
      }
    });
  }

  void startCountdownTimer(Duration countdown, VoidCallback onTick) {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      onTick();
    });
  }

  void stopCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void stopGlobalTimer() {
    _globalTimer?.cancel();
    _globalTimer = null;
  }

  void dispose() {
    stopGlobalTimer();
    stopCountdownTimer();
  }

  bool get isCountdownActive => _countdownTimer != null;
  bool get isGlobalTimerActive => _globalTimer != null;
}