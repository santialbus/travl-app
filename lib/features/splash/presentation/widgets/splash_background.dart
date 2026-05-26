import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SplashBackground extends StatelessWidget {
  final AnimationController controller;

  const SplashBackground({
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
          curve: Curves.easeIn,
        );

        return Opacity(
          opacity: curve.value,
          child: child,
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e), // Azul muy oscuro
              Color(0xFF0F0F0F), // Negro
              Color(0xFF16213e), // Azul oscuro
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}