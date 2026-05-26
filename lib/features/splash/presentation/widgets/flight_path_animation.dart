import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class FlightPathAnimation extends StatelessWidget {
  final AnimationController controller;

  const FlightPathAnimation({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final curve = CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        );

        return CustomPaint(
          size: const Size(200, 200),
          painter: _FlightPathPainter(progress: curve.value),
        );
      },
    );
  }
}

class _FlightPathPainter extends CustomPainter {
  final double progress;

  _FlightPathPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final path = Path();
    final start = Offset(center.dx - 70, center.dy + 20);
    final control1 = Offset(center.dx - 20, center.dy - 60);
    final control2 = Offset(center.dx + 20, center.dy - 60);
    final end = Offset(center.dx + 70, center.dy + 20);

    path.moveTo(start.dx, start.dy);
    path.cubicTo(
      control1.dx, control1.dy,
      control2.dx, control2.dy,
      end.dx, end.dy,
    );

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {

      // ✅ Trail — línea punteada recorrida
      _drawDashedPath(
        canvas,
        metric,
        progress,
      );

      // ✅ Punto viajero — minimalista
      if (progress > 0) {
        final tangent = metric.getTangentForOffset(
          metric.length * progress,
        );

        if (tangent != null) {
          final position = tangent.position;

          // Glow exterior
          final glowPaint = Paint()
            ..color = Colors.white.withOpacity(0.15)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
          canvas.drawCircle(position, 8, glowPaint);

          // Anillo exterior
          final ringPaint = Paint()
            ..color = AppColors.primary.withOpacity(0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;
          canvas.drawCircle(position, 5, ringPaint);

          // Punto central sólido
          final dotPaint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;
          canvas.drawCircle(position, 3, dotPaint);
        }
      }
    }

    // ✅ Ciudad origen — aparece desde el inicio
    _drawCityDot(canvas, start, 1.0);

    // ✅ Ciudad destino — aparece cuando el punto llega
    _drawCityDot(canvas, end, progress > 0.92 ? progress : 0.0);
  }

  void _drawDashedPath(
      Canvas canvas,
      PathMetric metric,
      double progress,
      ) {
    const dashLength = 4.0;
    const gapLength = 4.0;
    const step = dashLength + gapLength;

    final totalLength = metric.length * progress;
    double distance = 0;

    final dashPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.32)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    while (distance < totalLength) {
      final dashEnd = (distance + dashLength).clamp(0.0, totalLength);
      final dashPath = metric.extractPath(distance, dashEnd);
      canvas.drawPath(dashPath, dashPaint);
      distance += step;
    }
  }

  void _drawCityDot(Canvas canvas, Offset position, double opacity) {
    if (opacity <= 0) return;

    // Glow
    final glowPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.15 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(position, 8, glowPaint);

    // Anillo
    final ringPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.5 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(position, 4, ringPaint);

    // Punto
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(_FlightPathPainter oldDelegate) =>
      oldDelegate.progress != progress;
}