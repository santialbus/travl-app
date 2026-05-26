import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';

class AnimatedLogo extends StatelessWidget {
  final AnimationController controller;

  const AnimatedLogo({
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
          curve: Curves.elasticOut,
        );

        final fadeCurve = CurvedAnimation(
          parent: controller,
          curve: Curves.easeIn,
        );

        return Opacity(
          opacity: fadeCurve.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.5 + (0.5 * curve.value.clamp(0.0, 1.0)),
            child: child,
          ),
        );
      },
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(0.1),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        padding: const EdgeInsets.all(32),
        child: SvgPicture.asset(
          'assets/logo/travl_logo.svg',
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}