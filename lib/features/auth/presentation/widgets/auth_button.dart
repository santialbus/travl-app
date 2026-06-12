import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class AuthButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final bool useGoogleLogo;

  const AuthButton({
    super.key,
    required this.onPressed,
    this.icon,
    required this.label,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.useGoogleLogo = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (useGoogleLogo)
              const _GoogleLogo()
            else if (icon != null)
              Text(icon!, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.button.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// Google "G" logo drawn with the official 4-color scheme.
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final center = Offset(r, r);
    final strokeWidth = size.width * 0.22;

    final rect = Rect.fromCircle(center: center, radius: r - strokeWidth / 2);

    void drawArc(double startDeg, double sweepDeg, Color color) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        rect,
        startDeg * 3.14159265 / 180,
        sweepDeg * 3.14159265 / 180,
        false,
        paint,
      );
    }

    // Four arcs approximating the Google "G"
    drawArc(-10, -80, const Color(0xFF4285F4));   // blue (top-right)
    drawArc(-90, -90, const Color(0xFF34A853));   // green (bottom-right)
    drawArc(180, -90, const Color(0xFFFBBC05));   // yellow (bottom-left)
    drawArc(90, -80, const Color(0xFFEA4335));    // red (top-left)

    // Horizontal bar of the G
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(r * 0.15, r - strokeWidth * 0.45, r * 1.05, strokeWidth * 0.9),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
