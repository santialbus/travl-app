import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/route_constants.dart';
import 'widgets/animated_logo.dart';
import 'widgets/flight_path_animation.dart';
import 'widgets/splash_background.dart';
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _sceneController;
  late AnimationController _flightController;
  late AnimationController _textController;

  bool _showText = false;

  @override
  void initState() {
    super.initState();

    _sceneController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _flightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _start();
  }

  Future<void> _start() async {
    _sceneController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _flightController.forward();

    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() => _showText = true);
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 1200));
    _navigate();
  }

  void _navigate() {
    final user = FirebaseAuth.instance.currentUser;
    context.go(user != null ? RouteConstants.home : RouteConstants.auth);
  }

  @override
  void dispose() {
    _sceneController.dispose();
    _flightController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        children: [
          SplashScene(controller: _sceneController),

          Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: FlightLogoAnimation(
                controller: _flightController,
              ),
            ),
          ),

          // TEXT
          if (_showText)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: FadeTransition(
                  opacity: _textController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Travl',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          letterSpacing: 4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'PLAN IT. SHARE IT. LIVE IT.',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SplashScene extends StatelessWidget {
  final AnimationController controller;

  const SplashScene({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final opacity = Curves.easeIn.transform(controller.value);

        return Opacity(
          opacity: opacity,
          child: Stack(
            children: [
              // Gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0F172A),
                      Color(0xFF020617),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Glow
              Center(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.teal.withOpacity(0.15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.4),
                        blurRadius: 100,
                        spreadRadius: 20,
                      )
                    ],
                  ),
                ),
              ),

              // Moon
              Positioned(
                top: 120,
                right: 100,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Mountains
              CustomPaint(
                size: Size.infinite,
                painter: _MountainPainter(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0A2540);

    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..lineTo(size.width * 0.3, size.height * 0.5)
      ..lineTo(size.width * 0.6, size.height * 0.7)
      ..lineTo(size.width, size.height * 0.6)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class FlightLogoAnimation extends StatelessWidget {
  final AnimationController controller;

  const FlightLogoAnimation({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return CustomPaint(
          painter: _FlightPainter(controller.value),
        );
      },
    );
  }
}

class _FlightPainter extends CustomPainter {
  final double t;

  _FlightPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final start = Offset(center.dx - 60, center.dy + 40);
    final mid = Offset(center.dx, center.dy - 30);
    final end = Offset(center.dx + 70, center.dy + 20);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(mid.dx, mid.dy)
      ..quadraticBezierTo(
        center.dx + 40,
        center.dy - 80,
        end.dx,
        end.dy,
      );

    final metric = path.computeMetrics().first;
    final extract = metric.extractPath(0, metric.length * t);

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2 + (10 * t)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(extract, paint);

    // ✈️ Avión
    if (t < 0.95) {
      final tangent = metric.getTangentForOffset(metric.length * t);
      if (tangent != null) {
        final pos = tangent.position;

        canvas.save();
        canvas.translate(pos.dx, pos.dy);
        canvas.rotate(tangent.angle);

        final textPainter = TextPainter(
          text: const TextSpan(
            text: '✈',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(canvas, const Offset(-10, -10));
        canvas.restore();
      }
    }

    // 🔄 Morph a logo
    if (t > 0.85) {
      final opacity = (t - 0.85) * 6;

      final rect = Rect.fromCenter(
        center: center,
        width: 120,
        height: 120,
      );

      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(28));

      final fill = Paint()
        ..color = Colors.teal.withOpacity(opacity);

      canvas.drawRRect(rrect, fill);
    }
  }

  @override
  bool shouldRepaint(covariant _FlightPainter oldDelegate) =>
      oldDelegate.t != t;
}