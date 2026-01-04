import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:battery_plus/battery_plus.dart';

// ==========================================
// МОДЕЛЬ СЕСІЇ
// ==========================================
class GameSession {
  final String id, name, date, matchDuration;
  final int c1, c2, tries, total;
  final List<Map<String, dynamic>> grid;

  GameSession({
    required this.id,
    required this.name,
    required this.date,
    required this.c1,
    required this.c2,
    required this.tries,
    required this.total,
    required this.matchDuration,
    required this.grid,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'date': date,
    'c1': c1,
    'c2': c2,
    'tries': tries,
    'total': total,
    'matchDuration': matchDuration,
    'grid': grid,
  };

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      id: json['id']?.toString() ?? "",
      name: json['name']?.toString() ?? "Session",
      date: json['date']?.toString() ?? "--",
      c1: json['c1'] ?? 0,
      c2: json['c2'] ?? 0,
      tries: json['tries'] ?? 0,
      total: json['total'] ?? 0,
      matchDuration: json['matchDuration'] ?? "00:00:00",
      grid: List<Map<String, dynamic>>.from(json['grid'] ?? []),
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const CatchClickerApp());
}

class CatchClickerApp extends StatelessWidget {
  const CatchClickerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF121212),
    ),
    home: const ClickerScreen(),
  );
}

// ==========================================
// ГОЛОВНИЙ ЕКРАН
// ==========================================
class ClickerScreen extends StatefulWidget {
  const ClickerScreen({super.key});
  @override
  State<ClickerScreen> createState() => _ClickerScreenState();
}

class _ClickerScreenState extends State<ClickerScreen> {
  int counter1 = 0, counter2 = 0, tries = 0, total = 0;
  bool isPowerOn = true,
      isPaused = true,
      isActionDelay = false,
      hasHistory = false;
  bool isDataHidden = false, isVibeFlash = false, isSessionActive = false;

  Duration duration = Duration.zero;
  Duration matchInterval = const Duration(hours: 5); // Default 5 hours
  int resetDelay = 15, vibeInterval = 60, delayCountdown = 0;

  String realTime = "--:--:--", currentDate = "--.--.--";
  int batteryLevel = 0;
  final Battery _battery = Battery();
  Timer? timer, countdownTimer;
  List<Map<String, dynamic>> activityGrid = [];
  final ScrollController _gridScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _startGlobalTimer();
  }

  void _startGlobalTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted || !isPowerOn) return;
      final now = DateTime.now();
      int level = 0;
      try {
        level = await _battery.batteryLevel;
      } catch (_) {}

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
    });
  }

  void _triggerVibeFeedback() {
    HapticFeedback.vibrate();
    setState(() => isVibeFlash = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        HapticFeedback.vibrate();
        setState(() => isVibeFlash = false);
      }
    });
  }

  void handleIncrement(int type) {
    if (!isPowerOn || isActionDelay || isPaused || !isSessionActive) return;
    int sec = duration.inSeconds;
    String status = (sec >= vibeInterval * 0.9 && sec <= vibeInterval * 1.1)
        ? "green"
        : (sec < vibeInterval * 0.7
              ? "grey"
              : (sec > vibeInterval * 1.5 ? "red" : "orange"));
    HapticFeedback.mediumImpact();
    setState(() {
      if (type == 1) counter1++;
      if (type == 2) counter2++;
      if (type == 3) tries++;
      total = counter1 + counter2;
      activityGrid.add({
        "type": type,
        "status": status,
        "interval": sec,
        "target": vibeInterval,
        "timestamp": DateFormat('HH:mm:ss').format(DateTime.now()),
      });
      duration = Duration.zero;
      isActionDelay = true;
      delayCountdown = resetDelay;
    });
    _scrollToEnd();
    _saveData();
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
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
    setState(() {
      if (!isSessionActive) isSessionActive = true;
      isPaused = !isPaused;
      if (isPaused) {
        isDataHidden = true;
        duration = Duration.zero;
        activityGrid.add({
          "type": 0,
          "status": "grey",
          "interval": 0,
          "timestamp": DateFormat('HH:mm:ss').format(DateTime.now()),
        });
        _scrollToEnd();
      } else {
        isDataHidden = false;
      }
    });
    _saveData();
  }

  // --- UI LCD ---
  Widget _buildLCD() {
    String f(int n) => n.toString().padLeft(2, '0');
    String formatMatch(Duration d) {
      String days = d.inDays > 0 ? "${d.inDays}d " : "";
      return "$days${f(d.inHours % 24)}:${f(d.inMinutes % 60)}:${f(d.inSeconds % 60)}";
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
                          "$batteryLevel%",
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
                        _lcdStat("C1", isDataHidden ? null : counter1),
                        _lcdStat(
                          "TOTAL",
                          isDataHidden ? null : total,
                          isBold: true,
                        ),
                        _lcdStat("C2", isDataHidden ? null : counter2),
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
                                "BUSY ${f(delayCountdown)}s",
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
                              "${f(duration.inHours)}:${f(duration.inMinutes % 60)}:${f(duration.inSeconds % 60)}",
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
        int type = e['type'] is int ? e['type'] : 0;
        IconData icon = type == 0
            ? Icons.close
            : (type == 1
                  ? Icons.stop
                  : (type == 2 ? Icons.change_history : Icons.circle));
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

  Widget _lcdStat(String l, int? v, {bool isBold = false}) => Column(
    children: [
      Text(l, style: const TextStyle(color: Colors.black, fontSize: 9)),
      Text(
        v == null ? "--" : "$v",
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
        ),
      ),
    ],
  );

  // --- УПРАВЛІННЯ ---
  Widget _buildControls() {
    double mainS = 75.0;
    return Expanded(
      flex: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _btn("C 1", () => handleIncrement(1), mainS, isActionBtn: true),
              _btn(
                "Try",
                () => handleIncrement(3),
                55,
                isSmall: true,
                isActionBtn: true,
              ),
              _btn("C 2", () => handleIncrement(2), mainS, isActionBtn: true),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _btn(
                isPaused ? "START" : "PAUSE",
                togglePause,
                mainS,
                isAccent: true,
              ),
              _btn("SETTINGS", _showSettings, mainS, isSmall: true),
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
    String l,
    VoidCallback t,
    double s, {
    bool isSmall = false,
    bool isAccent = false,
    bool isActionBtn = false,
  }) {
    bool isDisabled =
        !isPowerOn ||
        (isActionBtn && (!isSessionActive || isPaused || isActionDelay));
    return GestureDetector(
      onTap: isDisabled ? null : t,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isDisabled ? 0.12 : 1.0,
        child: Container(
          width: s,
          height: s,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isAccent
                ? (isPaused ? Colors.green.shade100 : Colors.orange.shade100)
                : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(width: 3, color: Colors.black),
          ),
          child: Text(
            l,
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
        title: const Text("Settings"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: rCtrl,
                decoration: const InputDecoration(
                  labelText: "Action Delay (s)",
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: vCtrl,
                decoration: const InputDecoration(
                  labelText: "Vibe Interval (s)",
                ),
                keyboardType: TextInputType.number,
              ),
              const Divider(),
              const Text("Match Duration:"),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dCtrl,
                      decoration: const InputDecoration(labelText: "Days"),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: hCtrl,
                      decoration: const InputDecoration(labelText: "Hrs"),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: mCtrl,
                      decoration: const InputDecoration(labelText: "Mins"),
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
                resetDelay = int.tryParse(rCtrl.text) ?? 15;
                vibeInterval = int.tryParse(vCtrl.text) ?? 60;
                matchInterval = Duration(
                  days: int.tryParse(dCtrl.text) ?? 0,
                  hours: int.tryParse(hCtrl.text) ?? 0,
                  minutes: int.tryParse(mCtrl.text) ?? 0,
                );
              });
              _saveData();
              Navigator.pop(c);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // --- DATA ---
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      counter1 = prefs.getInt('counter1') ?? 0;
      counter2 = prefs.getInt('counter2') ?? 0;
      tries = prefs.getInt('tries') ?? 0;
      total = prefs.getInt('total') ?? 0;
      isPowerOn = prefs.getBool('power') ?? true;
      isPaused = prefs.getBool('paused') ?? true;
      resetDelay = prefs.getInt('reset_delay') ?? 15;
      vibeInterval = prefs.getInt('vibe_interval') ?? 60;
      matchInterval = Duration(seconds: prefs.getInt('match_seconds') ?? 18000);
      hasHistory = (prefs.getStringList('history_sessions') ?? []).isNotEmpty;
      String? gridJson = prefs.getString('activity_grid_final');
      if (gridJson != null)
        activityGrid = List<Map<String, dynamic>>.from(jsonDecode(gridJson));
      if (isPaused) {
        isDataHidden = true;
        duration = Duration.zero;
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter1', counter1);
    await prefs.setInt('counter2', counter2);
    await prefs.setInt('tries', tries);
    await prefs.setInt('total', total);
    await prefs.setBool('power', isPowerOn);
    await prefs.setBool('paused', isPaused);
    await prefs.setInt('reset_delay', resetDelay);
    await prefs.setInt('vibe_interval', vibeInterval);
    await prefs.setInt('match_seconds', matchInterval.inSeconds);
    await prefs.setString('activity_grid_final', jsonEncode(activityGrid));
  }

  void _scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_gridScrollController.hasClients)
        _gridScrollController.jumpTo(
          _gridScrollController.position.maxScrollExtent,
        );
    });
  }

  Future<void> _handlePower() async {
    if (!isPowerOn) {
      setState(() => isPowerOn = true);
      return;
    }
    final nameCtrl = TextEditingController(
      text: "Session ${DateFormat('HH:mm').format(DateTime.now())}",
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Save Session?"),
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
            child: const Text("Off"),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              List<String> history =
                  prefs.getStringList('history_sessions') ?? [];
              final session = GameSession(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameCtrl.text,
                date: DateFormat('dd.MM.yy HH:mm').format(DateTime.now()),
                c1: counter1,
                c2: counter2,
                tries: tries,
                total: total,
                matchDuration:
                    "${matchInterval.inHours}:${matchInterval.inMinutes % 60}",
                grid: List.from(activityGrid),
              );
              history.add(jsonEncode(session.toJson()));
              await prefs.setStringList('history_sessions', history);
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
              _saveData();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
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

// ==========================================
// ІСТОРІЯ ТА АНАЛІТИКА
// ==========================================
class HistoryScreen extends StatefulWidget {
  final VoidCallback onHistoryUpdate;
  const HistoryScreen({super.key, required this.onHistoryUpdate});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<GameSession> sessions = [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('history_sessions') ?? [];
    setState(
      () => sessions = data
          .map((e) => GameSession.fromJson(jsonDecode(e)))
          .toList()
          .reversed
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("History")),
    body: ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (c, i) => ListTile(
        title: Text(sessions[i].name),
        subtitle: Text(sessions[i].date),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => AnalyticsScreen(session: sessions[i]),
          ),
        ),
      ),
    ),
  );
}

// ==========================================
// ЕКРАН АНАЛІТИКИ (ВИПРАВЛЕНО)
// ==========================================
class AnalyticsScreen extends StatelessWidget {
  final GameSession session;

  // ВИПРАВЛЕНО: Кома замість двокрапки та додано this.session
  const AnalyticsScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    // 1. Розрахунок статистики
    final validClicks = session.grid
        .where((e) => _toInt(e['type']) != 0)
        .toList();

    double avgInterval = 0;
    double avgDeviation = 0;

    if (validClicks.isNotEmpty) {
      double sumInt = 0;
      double sumDiff = 0;
      for (var e in validClicks) {
        double actual = _toDouble(e['interval']);
        double target = _toDouble(e['target'] ?? 60.0);
        sumInt += actual;
        sumDiff += (actual - target);
      }
      avgInterval = sumInt / validClicks.length;
      avgDeviation = sumDiff / validClicks.length;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Precision Report")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            Text(
              "Дата: ${session.date} | Тривалість: ${session.matchDuration}",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const Divider(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statBox("C1", session.c1),
                _statBox("TOTAL", session.total, isHero: true),
                _statBox("C2", session.c2),
              ],
            ),
            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  _avgIndicator(
                    "AVG VIBE",
                    "${avgInterval.toStringAsFixed(1)}s",
                    Colors.white,
                  ),
                  Container(width: 1, height: 30, color: Colors.white24),
                  _avgIndicator(
                    "DEVIATION",
                    "${avgDeviation > 0 ? '+' : ''}${avgDeviation.toStringAsFixed(2)}s",
                    avgDeviation.abs() < 1.5
                        ? Colors.green
                        : (avgDeviation.abs() < 4 ? Colors.orange : Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              "Activity Timeline:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: session.grid.length,
              itemBuilder: (c, i) {
                final e = session.grid[i];
                int type = _toInt(e['type']);

                IconData icon;
                String label;
                if (type == 0) {
                  icon = Icons.pause_circle_filled;
                  label = "PAUSE / RESET";
                } else if (type == 1) {
                  icon = Icons.stop;
                  label = "C1 Click";
                } else if (type == 2) {
                  icon = Icons.change_history;
                  label = "C2 Click";
                } else {
                  icon = Icons.circle;
                  label = "Try Error";
                }

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(icon, color: _getColor(e['status'])),
                  title: Text(label, style: const TextStyle(fontSize: 14)),
                  subtitle: Text(
                    e['timestamp'] ?? "--:--:--",
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: type != 0
                      ? Text(
                          "${e['interval']}s",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      : const Text("-", style: TextStyle(color: Colors.grey)),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  int _toInt(dynamic v) => v is int ? v : int.tryParse(v.toString()) ?? 0;
  double _toDouble(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0;

  Color _getColor(dynamic s) {
    switch (s?.toString()) {
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'grey':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  Widget _statBox(String l, int v, {bool isHero = false}) => Column(
    children: [
      Text(l, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      Text(
        "$v",
        style: TextStyle(
          fontSize: isHero ? 32 : 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );

  Widget _avgIndicator(String l, String v, Color c) => Expanded(
    child: Column(
      children: [
        Text(l, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        Text(
          v,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c),
        ),
      ],
    ),
  );
}
