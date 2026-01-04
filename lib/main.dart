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

  Duration duration = Duration.zero; // Vibe Timer
  Duration matchInterval = const Duration(hours: 5); // Session Timer
  int resetDelay = 15, vibeInterval = 60;
  int delayCountdown = 0; // Зворотний відлік для BUSY

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

        // Загальний час сесії (не зупиняється на паузі)
        if (isSessionActive && matchInterval.inSeconds > 0) {
          matchInterval -= const Duration(seconds: 1);
        }

        // Таймер Vibe (скидається на паузі, стоїть під час BUSY)
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
    String status = "orange";
    int sec = duration.inSeconds;
    if (sec >= vibeInterval * 0.9 && sec <= vibeInterval * 1.1)
      status = "green";
    else if (sec < vibeInterval * 0.7)
      status = "grey";
    else if (sec > vibeInterval * 1.5)
      status = "red";

    String ts = DateFormat('HH:mm:ss').format(DateTime.now());
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
        "timestamp": ts,
      });

      duration = Duration.zero;
      isActionDelay = true;
      delayCountdown = resetDelay;
    });

    _scrollToEnd();
    _saveData();

    // Запуск відліку для LCD та розблокування
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
    String ts = DateFormat('HH:mm:ss').format(DateTime.now());
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
          "target": vibeInterval,
          "timestamp": ts,
        });
        _scrollToEnd();
      } else {
        isDataHidden = false;
      }
    });
    _saveData();
  }

  void _scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_gridScrollController.hasClients)
        _gridScrollController.jumpTo(
          _gridScrollController.position.maxScrollExtent,
        );
    });
  }

  // --- UI LCD ---
  Widget _buildLCD() {
    String f(int n) => n.toString().padLeft(2, '0');
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
                    // Верхній рядок: Дата, Реальний час, Батарея
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
                    // Показники C1, Total, C2
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
                    const Divider(
                      color: Colors.black,
                      thickness: 1,
                      height: 10,
                    ),

                    // ЦЕНТРАЛЬНА ЧАСТИНА: ТАЙМЕР + BUSY (через Stack)
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Напис BUSY зверху (показується тільки при затримці)
                          if (isActionDelay)
                            Positioned(
                              top: 0,
                              child: Text(
                                "BUSY ${f(delayCountdown)}s",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          // Основний таймер Vibe
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
                                fontSize:
                                    60, // Збільшено, бо FittedBox захистить від overflow
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
                      height: 10,
                    ),
                    // Сітка активності (зменшено висоту до 70 для безпеки)
                    SizedBox(
                      height: 70,
                      child: buildActivityGrid(
                        activityGrid,
                        _gridScrollController,
                      ),
                    ),
                    const Divider(
                      color: Colors.black,
                      thickness: 1,
                      height: 10,
                    ),
                    // Таймер сесії (Match Duration)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "${f(matchInterval.inHours)}:${f(matchInterval.inMinutes % 60)}:${f(matchInterval.inSeconds % 60)}",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 38,
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

  static Widget buildActivityGrid(
    List<Map<String, dynamic>> data,
    ScrollController? ctrl,
  ) {
    return GridView.builder(
      controller: ctrl,
      scrollDirection: Axis.horizontal,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 4,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final e = data[index];
        int type = e['type'] is int
            ? e['type']
            : int.tryParse(e['type'].toString()) ?? 0;
        IconData icon = type == 0
            ? Icons.close
            : (type == 1
                  ? Icons.stop
                  : (type == 2 ? Icons.change_history : Icons.circle));
        Color color = getStatusColor(e['status']?.toString());
        return Icon(icon, size: 22, color: color);
      },
    );
  }

  static Color getStatusColor(String? status) {
    switch (status) {
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

  // --- CONTROLS ---
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
    // Повне блокування логіки
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
      String? gridJson = prefs.getString('activity_grid_v20');
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
    await prefs.setString('activity_grid_v20', jsonEncode(activityGrid));
  }

  void _showSettings() {
    if (!isPowerOn) return;
    final rCtrl = TextEditingController(text: resetDelay.toString());
    final vCtrl = TextEditingController(text: vibeInterval.toString());
    final mCtrl = TextEditingController(
      text: (matchInterval.inMinutes).toString(),
    );
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Settings"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: rCtrl,
              decoration: const InputDecoration(labelText: "Action Delay (s)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: vCtrl,
              decoration: const InputDecoration(labelText: "Vibe Interval (s)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: mCtrl,
              decoration: const InputDecoration(
                labelText: "Match Duration (min)",
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                resetDelay = int.parse(rCtrl.text);
                vibeInterval = int.parse(vCtrl.text);
                matchInterval = Duration(minutes: int.parse(mCtrl.text));
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
                date: DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now()),
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
  Widget build(BuildContext context) => Scaffold(
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

// Екрани HistoryScreen та AnalyticsScreen (залишаються без змін)
// ... [Додайте коди HistoryScreen та AnalyticsScreen з версії 1.9 тут] ...

// ==========================================
// ЕКРАН ІСТОРІЇ
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
    body: sessions.isEmpty
        ? const Center(child: Text("Empty"))
        : ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (c, i) => Dismissible(
              key: Key(sessions[i].id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete),
              ),
              onDismissed: (dir) async {
                final prefs = await SharedPreferences.getInstance();
                List<String> data =
                    prefs.getStringList('history_sessions') ?? [];
                data.removeWhere(
                  (item) =>
                      GameSession.fromJson(jsonDecode(item)).id ==
                      sessions[i].id,
                );
                await prefs.setStringList('history_sessions', data);
                widget.onHistoryUpdate();
                _load();
              },
              child: ListTile(
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
          ),
  );
}

// ==========================================
// ЕКРАН АНАЛІТИКИ (PRECISION PRO)
// ==========================================
class AnalyticsScreen extends StatelessWidget {
  final GameSession session;
  const AnalyticsScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
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
        double target = _toDouble(e['target'] ?? actual);
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
              session.date,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat("C1", session.c1),
                _stat("TOTAL", session.total, isHero: true),
                _stat("C2", session.c2),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  _avgBox(
                    "AVG VIBE",
                    "${avgInterval.toStringAsFixed(1)}s",
                    Colors.white,
                  ),
                  Container(width: 1, height: 30, color: Colors.white24),
                  _avgBox(
                    "DEVIATION",
                    "${avgDeviation > 0 ? '+' : ''}${avgDeviation.toStringAsFixed(2)}s",
                    avgDeviation.abs() < 1
                        ? Colors.green
                        : (avgDeviation.abs() < 3 ? Colors.orange : Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Timeline & Target Shifts:",
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
                final prev = i > 0 ? session.grid[i - 1] : null;
                int type = _toInt(e['type']);
                int curTarget = _toInt(e['target'] ?? 0);
                int prevTarget = prev != null
                    ? _toInt(prev['target'] ?? 0)
                    : curTarget;
                bool targetShifted =
                    i == 0 || (curTarget != prevTarget && curTarget != 0);

                return Column(
                  children: [
                    if (targetShifted) _buildTargetBanner(curTarget),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            _getIcon(type),
                            size: 20,
                            color: _getColor(e['status']),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getLabel(type),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  e['timestamp']?.toString() ?? "--:--:--",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (type != 0)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${e['interval']}s",
                                  style: TextStyle(
                                    color: _getColor(e['status']),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const Text(
                                  "vibe",
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetBanner(int target) => Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 10),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.orange.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.orange.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "TARGET SHIFTED",
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        Text(
          "${target}s",
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: Colors.orange,
          ),
        ),
      ],
    ),
  );

  int _toInt(dynamic v) => v is int ? v : int.tryParse(v.toString()) ?? 0;
  double _toDouble(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0;
  IconData _getIcon(int t) => t == 0
      ? Icons.pause_circle_filled
      : (t == 1 ? Icons.stop : (t == 2 ? Icons.change_history : Icons.circle));
  String _getLabel(int t) => t == 0
      ? "PAUSE"
      : (t == 1 ? "C1 Click" : (t == 2 ? "C2 Click" : "Try Error"));
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

  Widget _stat(String l, int v, {bool isHero = false}) => Column(
    children: [
      Text(l, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      Text(
        "$v",
        style: TextStyle(
          fontSize: isHero ? 30 : 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
  Widget _avgBox(String l, String v, Color c) => Expanded(
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
