import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class AuthButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const AuthButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
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
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 20),
            ),
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