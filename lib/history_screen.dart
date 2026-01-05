// ==========================================
// ІСТОРІЯ ТА АНАЛІТИКА
// ==========================================
import 'dart:convert';

import 'package:fish_counter/analytics_screen.dart';
import 'package:fish_counter/game_session.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
