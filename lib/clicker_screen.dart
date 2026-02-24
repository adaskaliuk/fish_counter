// ==========================================
// ГОЛОВНИЙ ЕКРАН
// ==========================================
import 'dart:async';
import 'dart:convert';

import 'package:battery_plus/battery_plus.dart';
import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==========================================
// CONSTANTS
// ==========================================
class _PrefsKeys {
  static const String counter1 = 'counter1';
  static const String counter2 = 'counter2';
  static const String tries = 'tries';
  static const String total = 'total';
  static const String power = 'power';
  static const String paused = 'paused';
  static const String resetDelay = 'reset_delay';
  static const String vibeInterval = 'vibe_interval';
  static const String matchSeconds = 'match_seconds';
  static const String activityGrid = 'activity_grid_final';
  static const String historySessions = 'history_sessions';
}

class _Defaults {
  static const int resetDelaySeconds = 15;
  static const int vibeIntervalSeconds = 60;
  static const int matchDurationSeconds = 18000; // 5 hours
  static const int actionDelayMs = 600;
  static const int scrollDelayMs = 100;
}

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

  // Timers
  Duration duration = Duration.zero;
  Duration matchInterval =
      const Duration(seconds: _Defaults.matchDurationSeconds);
  int resetDelay = _Defaults.resetDelaySeconds;
  int vibeInterval = _Defaults.vibeIntervalSeconds;
  int delayCountdown = 0;

  // Display
  String realTime = '--:--:--';
  String currentDate = '--.--.--';
  int batteryLevel = 0;

  // Services
  final Battery _battery = Battery();
  Timer? _timer;
  Timer? _countdownTimer;

  // Activity grid
  List<Map<String, dynamic>> activityGrid = [];
  final ScrollController _gridScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _startGlobalTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    _gridScrollController.dispose();
    super.dispose();
  }

  void _startGlobalTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted || !isPowerOn) return;

      try {
        final now = DateTime.now();
        int level = 0;
        try {
          level = await _battery.batteryLevel;
        } catch (e) {
          debugPrint('Battery level error: $e');
        }

        if (!mounted) return;

        setState(() {
          realTime = DateFormat('HH:mm:ss').format(now);
          currentDate = DateFormat('dd.MM.yy').format(now);
          batteryLevel = level;

          if (isSessionActive && matchInterval.inSeconds > 0) {
            matchInterval -= const Duration(seconds: 1);
          }

          if (!isPaused && isSessionActive && !isActionDelay) {
            duration += const Duration(seconds: 1);
            if (vibeInterval > 0 &&
                duration.inSeconds != 0 &&
                duration.inSeconds % vibeInterval == 0) {
              _triggerVibeFeedback();
            }
          }
        });
      } catch (e) {
        debugPrint('Timer error: $e');
      }
    });
  }

  void _triggerVibeFeedback() {
    HapticFeedback.vibrate();
    if (!mounted) return;
    setState(() => isVibeFlash = true);

    Future.delayed(const Duration(milliseconds: _Defaults.actionDelayMs), () {
      if (!mounted) return;
      HapticFeedback.vibrate();
      setState(() => isVibeFlash = false);
    });
  }

  void handleIncrement(int type) {
    if (!isPowerOn || isActionDelay || isPaused || !isSessionActive) return;

    final sec = duration.inSeconds;
    final status = _calculateStatus(sec);

    HapticFeedback.mediumImpact();

    setState(() {
      if (type == 1) counter1++;
      if (type == 2) counter2++;
      if (type == 3) tries++;
      total = counter1 + counter2;

      activityGrid.add({
        'type': type,
        'status': status,
        'interval': sec,
        'target': vibeInterval,
        'timestamp': DateFormat('HH:mm:ss').format(DateTime.now()),
      });

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

  String _calculateStatus(int seconds) {
    if (seconds >= vibeInterval * 0.9 && seconds <= vibeInterval * 1.1) {
      return 'green';
    } else if (seconds < vibeInterval * 0.7) {
      return 'grey';
    } else if (seconds > vibeInterval * 1.5) {
      return 'red';
    } else {
      return 'orange';
    }
  }

  void togglePause() {
    setState(() {
      if (!isSessionActive) isSessionActive = true;
      isPaused = !isPaused;

      if (isPaused) {
        isDataHidden = true;
        duration = Duration.zero;
        activityGrid.add({
          'type': 0,
          'status': 'grey',
          'interval': 0,
          'timestamp': DateFormat('HH:mm:ss').format(DateTime.now()),
        });
        _scrollToEnd();
      } else {
        isDataHidden = false;
      }
    });
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                        _lcdStat('TOTAL', isDataHidden ? null : total,
                            isBold: true),
                        _lcdStat('C2', isDataHidden ? null : counter2),
                      ],
                    ),
                    const Divider(
                      color: Colors.black,
                      thickness: 1,
                      height: 8,
                    ),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (isActionDelay)
                            Positioned(
                              top: 2,
                              child: Text(
                                'BUSY ${f(delayCountdown)}s',
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
                    const Divider(
                      color: Colors.black,
                      thickness: 1,
                      height: 8,
                    ),
                    SizedBox(height: 70, child: _buildGrid()),
                    const Divider(
                      color: Colors.black,
                      thickness: 1,
                      height: 8,
                    ),
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
          Text(label,
              style: const TextStyle(color: Colors.black, fontSize: 9)),
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
    const double mainSize = 75.0;

    return Expanded(
      flex: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _btn('C 1', () => handleIncrement(1), mainSize,
                  isActionBtn: true),
              _btn('Try', () => handleIncrement(3), 55,
                  isSmall: true, isActionBtn: true),
              _btn('C 2', () => handleIncrement(2), mainSize,
                  isActionBtn: true),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _btn(isPaused ? 'START' : 'PAUSE', togglePause, mainSize,
                  isAccent: true),
              _btn('SETTINGS', _showSettings, mainSize, isSmall: true),
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
              const Expanded(child: SizedBox()),
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
  }) {
    final isDisabled = !isPowerOn ||
        (isActionBtn && (!isSessionActive || isPaused || isActionDelay));

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

  void _showSettings() {
    if (!isPowerOn) return;

    final rCtrl = TextEditingController(text: resetDelay.toString());
    final vCtrl = TextEditingController(text: vibeInterval.toString());
    final dCtrl = TextEditingController(text: matchInterval.inDays.toString());
    final hCtrl = TextEditingController(
      text: (matchInterval.inHours % 24).toString(),
    );
    final mCtrl = TextEditingController(
      text: (matchInterval.inMinutes % 60).toString(),
    );

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Settings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: rCtrl,
                decoration: const InputDecoration(labelText: 'Action Delay (s)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: vCtrl,
                decoration:
                    const InputDecoration(labelText: 'Vibe Interval (s)'),
                keyboardType: TextInputType.number,
              ),
              const Divider(),
              const Text('Match Duration:'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dCtrl,
                      decoration: const InputDecoration(labelText: 'Days'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: hCtrl,
                      decoration: const InputDecoration(labelText: 'Hrs'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: mCtrl,
                      decoration: const InputDecoration(labelText: 'Mins'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                resetDelay = int.tryParse(rCtrl.text) ?? _Defaults.resetDelaySeconds;
                vibeInterval = int.tryParse(vCtrl.text) ?? _Defaults.vibeIntervalSeconds;
                matchInterval = Duration(
                  days: int.tryParse(dCtrl.text) ?? 0,
                  hours: int.tryParse(hCtrl.text) ?? 0,
                  minutes: int.tryParse(mCtrl.text) ?? 0,
                );
              });
              _saveData();
              Navigator.pop(c);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // DATA PERSISTENCE
  // ==========================================
  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;

      setState(() {
        counter1 = prefs.getInt(_PrefsKeys.counter1) ?? 0;
        counter2 = prefs.getInt(_PrefsKeys.counter2) ?? 0;
        tries = prefs.getInt(_PrefsKeys.tries) ?? 0;
        total = prefs.getInt(_PrefsKeys.total) ?? 0;
        isPowerOn = prefs.getBool(_PrefsKeys.power) ?? true;
        isPaused = prefs.getBool(_PrefsKeys.paused) ?? true;
        resetDelay = prefs.getInt(_PrefsKeys.resetDelay) ?? _Defaults.resetDelaySeconds;
        vibeInterval = prefs.getInt(_PrefsKeys.vibeInterval) ?? _Defaults.vibeIntervalSeconds;
        matchInterval = Duration(
            seconds: prefs.getInt(_PrefsKeys.matchSeconds) ?? _Defaults.matchDurationSeconds);
        hasHistory =
            (prefs.getStringList(_PrefsKeys.historySessions) ?? []).isNotEmpty;

        final String? gridJson = prefs.getString(_PrefsKeys.activityGrid);
        if (gridJson != null) {
          try {
            activityGrid =
                List<Map<String, dynamic>>.from(jsonDecode(gridJson));
          } catch (e) {
            debugPrint('Error parsing activity grid: $e');
            activityGrid = [];
          }
        }

        if (isPaused) {
          isDataHidden = true;
          duration = Duration.zero;
        }
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_PrefsKeys.counter1, counter1);
      await prefs.setInt(_PrefsKeys.counter2, counter2);
      await prefs.setInt(_PrefsKeys.tries, tries);
      await prefs.setInt(_PrefsKeys.total, total);
      await prefs.setBool(_PrefsKeys.power, isPowerOn);
      await prefs.setBool(_PrefsKeys.paused, isPaused);
      await prefs.setInt(_PrefsKeys.resetDelay, resetDelay);
      await prefs.setInt(_PrefsKeys.vibeInterval, vibeInterval);
      await prefs.setInt(_PrefsKeys.matchSeconds, matchInterval.inSeconds);
      await prefs.setString(_PrefsKeys.activityGrid, jsonEncode(activityGrid));
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  void _scrollToEnd() {
    Future.delayed(const Duration(milliseconds: _Defaults.scrollDelayMs), () {
      if (mounted && _gridScrollController.hasClients) {
        _gridScrollController.jumpTo(
          _gridScrollController.position.maxScrollExtent,
        );
      }
    });
  }

  Future<void> _handlePower() async {
    if (!isPowerOn) {
      setState(() => isPowerOn = true);
      return;
    }

    final nameCtrl = TextEditingController(
      text: 'Session ${DateFormat('HH:mm').format(DateTime.now())}',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Save Session?'),
        content: TextField(controller: nameCtrl),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                isPowerOn = false;
                isSessionActive = false;
              });
            },
            child: const Text('Off'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              try {
                final prefs = await SharedPreferences.getInstance();
                final List<String> history =
                    prefs.getStringList(_PrefsKeys.historySessions) ?? [];

                final session = GameSession(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameCtrl.text,
                  date: DateFormat('dd.MM.yy HH:mm').format(DateTime.now()),
                  c1: counter1,
                  c2: counter2,
                  tries: tries,
                  total: total,
                  matchDuration:
                      '${matchInterval.inHours}:${matchInterval.inMinutes % 60}',
                  grid: List.from(activityGrid),
                );

                history.add(jsonEncode(session.toJson()));
                await prefs.setStringList(_PrefsKeys.historySessions, history);

                if (!mounted) return;

                setState(() {
                  counter1 = 0;
                  counter2 = 0;
                  tries = 0;
                  total = 0;
                  activityGrid = [];
                  isPowerOn = false;
                  hasHistory = true;
                  isPaused = true;
                  isSessionActive = false;
                });

                await _saveData();

                if (!mounted) return;
                navigator.pop();
              } catch (e) {
                debugPrint('Error saving session: $e');
                if (!mounted) return;
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text('Error saving session: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
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
