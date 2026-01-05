// ==========================================
// ЕКРАН АНАЛІТИКИ (ВИПРАВЛЕНО)
// ==========================================
import 'package:fish_counter/game_session.dart';
import 'package:flutter/material.dart';

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
