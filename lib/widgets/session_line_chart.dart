import 'package:flutter/material.dart';

import 'session_line_chart_painter.dart';

class ChartPoint {
  final double x;
  final double y;

  const ChartPoint(this.x, this.y);
}

class SessionLineChart extends StatelessWidget {
  final List<ChartPoint> points;
  final Color accent;

  const SessionLineChart({
    super.key,
    required this.points,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SessionLineChartPainter(points: points, accent: accent),
      child: const SizedBox.expand(),
    );
  }
}
