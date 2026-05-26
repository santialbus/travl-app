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
  late AnimationController _backgroundController;
  late AnimationController _logoController;
  late AnimationController _planeController;
  late AnimationController _textController;

  bool _showPlane = false;
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _startAnimation();
  }

  void _initControllers() {
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _planeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  Future<void> _startAnimation() async {
    // 0.0s - Fondo fade in
    await Future.delayed(const Duration(milliseconds: 100));
    _backgroundController.forward();

    // 0.6s - Logo aparece
    await Future.delayed(const Duration(milliseconds: 500));
    _logoController.forward();

    // 1.3s - Avión recorre ruta
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() => _showPlane = true);
    _planeController.forward();

    // 2.0s - Texto aparece
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() => _showText = true);
    _textController.forward();

    // 2.8s - Navegar
    await Future.delayed(const Duration(milliseconds: 800));
    _navigate();
  }

  void _navigate() {
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      context.go(RouteConstants.home);
    } else {
      context.go(RouteConstants.auth);
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _logoController.dispose();
    _planeController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Background
          SplashBackground(controller: _backgroundController),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo + Plane animation
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Logo SVG animado
                      AnimatedLogo(controller: _logoController),

                      // Avión recorriendo ruta
                      if (_showPlane)
                        FlightPathAnimation(controller: _planeController),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Texto Travl
                // Texto Travl
                if (_showText)
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      final curve = CurvedAnimation(
                        parent: _textController,
                        curve: Curves.easeOut,
                      );

                      return Opacity(
                        opacity: curve.value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - curve.value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        // ✅ Travl grande
                        Text(
                          'Travl',
                          style: AppTextStyles.h1.copyWith(
                            color: Colors.white,
                            fontSize: 48,
                            letterSpacing: 4,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ✅ Tagline pequeño y elegante
                        Text(
                          'Plan your adventures together.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white38,
                            letterSpacing: 1.5,
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}