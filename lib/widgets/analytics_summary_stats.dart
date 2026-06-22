import 'package:fish_counter/game_session.dart';
import 'package:flutter/material.dart';

class AnalyticsSummaryStats extends StatelessWidget {
  const AnalyticsSummaryStats({
    super.key,
    required this.session,
    required this.averageInterval,
    required this.averageDeviation,
    required this.avgVibeLabel,
    required this.deviationLabel,
  });

  final GameSession session;
  final double averageInterval;
  final double averageDeviation;
  final String avgVibeLabel;
  final String deviationLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statBox('C1', session.c1),
            _statBox('TOTAL', session.total, isHero: true),
            _statBox('C2', session.c2),
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
                avgVibeLabel,
                '${averageInterval.toStringAsFixed(1)}s',
                Colors.white,
              ),
              Container(width: 1, height: 30, color: Colors.white24),
              _avgIndicator(
                deviationLabel,
                '${averageDeviation > 0 ? '+' : ''}${averageDeviation.toStringAsFixed(2)}s',
                averageDeviation.abs() < 1.5
                    ? Colors.green
                    : averageDeviation.abs() < 4
                    ? Colors.orange
                    : Colors.red,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statBox(String label, int value, {bool isHero = false}) {
    return Container(
      constraints: const BoxConstraints(minWidth: 80),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isHero ? Colors.orange.withValues(alpha: 0.18) : Colors.white10,
        borderRadius: BorderRadius.circular(14),
        border: isHero ? Border.all(color: Colors.orange, width: 1.5) : null,
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: TextStyle(
              color: isHero ? Colors.orange : Colors.white,
              fontSize: isHero ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _avgIndicator(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
