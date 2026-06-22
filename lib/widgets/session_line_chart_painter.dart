import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'session_line_chart.dart';

class SessionLineChartPainter extends CustomPainter {
  final List<ChartPoint> points;
  final Color accent;

  const SessionLineChartPainter({required this.points, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    const left = 28.0;
    const right = 8.0;
    const top = 10.0;
    const bottom = 22.0;
    final chart = Rect.fromLTWH(
      left,
      top,
      size.width - left - right,
      size.height - top - bottom,
    );
    final axisPaint = Paint()
      ..color = Colors.white.withValues(alpha: .10)
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [accent.withValues(alpha: .55), accent],
      ).createShader(chart)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final dotPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.fill;
    final glowPaint = Paint()
      ..color = accent.withValues(alpha: .18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [accent.withValues(alpha: .22), accent.withValues(alpha: .02)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(chart);

    for (var i = 0; i <= 3; i++) {
      final y = chart.top + chart.height * i / 3;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), axisPaint);
    }

    if (points.isEmpty) return;

    final minX = points.map((point) => point.x).reduce(math.min);
    final maxX = points.map((point) => point.x).reduce(math.max);
    final minY = points.map((point) => point.y).reduce(math.min);
    final maxY = points.map((point) => point.y).reduce(math.max);
    final xSpan = math.max(1, maxX - minX);
    final ySpan = math.max(1, maxY - minY);

    Offset mapPoint(ChartPoint point) {
      final x = chart.left + ((point.x - minX) / xSpan) * chart.width;
      final y = chart.bottom - ((point.y - minY) / ySpan) * chart.height;
      return Offset(x, y);
    }

    final first = mapPoint(points.first);
    final path = Path()..moveTo(first.dx, first.dy);
    for (final point in points.skip(1)) {
      final offset = mapPoint(point);
      path.lineTo(offset.dx, offset.dy);
    }
    final last = mapPoint(points.last);
    final fillPath = Path.from(path)
      ..lineTo(last.dx, chart.bottom)
      ..lineTo(first.dx, chart.bottom)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);

    for (final point in points) {
      canvas.drawCircle(mapPoint(point), 3.5, dotPaint);
    }

    _label(
      canvas,
      chart,
      maxY.toStringAsFixed(maxY % 1 == 0 ? 0 : 1),
      chart.top,
    );
    _label(
      canvas,
      chart,
      minY.toStringAsFixed(minY % 1 == 0 ? 0 : 1),
      chart.bottom - 12,
    );
  }

  void _label(Canvas canvas, Rect chart, String text, double y) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: .38),
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset(0, y));
  }

  @override
  bool shouldRepaint(covariant SessionLineChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.accent != accent;
  }
}
