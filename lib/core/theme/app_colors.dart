import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors (Modern, Travel-inspired)
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5443C7);
  static const Color primaryLight = Color(0xFF8B7EED);

  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentLight = Color(0xFFFF8888);

  // Background Colors (Dark Mode Elegant)
  static const Color backgroundDark = Color(0xFF0F0F0F);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color cardDark = Color(0xFF252525);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF707070);

  // Activity Type Colors
  static const Color flightColor = Color(0xFF4ECDC4);
  static const Color transportColor = Color(0xFF95E1D3);
  static const Color foodColor = Color(0xFFFFBE76);
  static const Color barColor = Color(0xFFFF6B9D);
  static const Color placeColor = Color(0xFF6C5CE7);
  static const Color hotelColor = Color(0xFF74B9FF);
  static const Color noteColor = Color(0xFFA29BFE);
  static const Color expenseColor = Color(0xFFFF7675);

  // Semantic Colors
  static const Color success = Color(0xFF00D9A3);
  static const Color warning = Color(0xFFFECA57);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF74B9FF);

  // Neutral Colors
  static const Color divider = Color(0xFF2C2C2C);
  static const Color border = Color(0xFF333333);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Get activity color by type
  static Color getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'flight':
        return flightColor;
      case 'transport':
        return transportColor;
      case 'food':
        return foodColor;
      case 'bar':
        return barColor;
      case 'place':
        return placeColor;
      case 'hotel':
        return hotelColor;
      case 'note':
        return noteColor;
      case 'expense':
        return expenseColor;
      default:
        return primary;
    }
  }
  // Light Mode Colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  static const Color textPrimaryLight = Color(0xFF0F0F0F);
  static const Color textSecondaryLight = Color(0xFF555555);
  static const Color textTertiaryLight = Color(0xFF999999);

  static const Color dividerLight = Color(0xFFE5E5E5);
  static const Color borderLight = Color(0xFFE0E0E0);

// ============ ADAPTIVE HELPERS ============
// Usar estos en todos los widgets en lugar de los colores hardcodeados

  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : backgroundLight;
  }

  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? surfaceDark
        : surfaceLight;
  }

  static Color card(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? cardDark
        : cardLight;
  }

  /*static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFFFFFFF)
        : textPrimaryLight;
  }

  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFB0B0B0)
        : textSecondaryLight;
  }

  static Color textTertiary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF707070)
        : textTertiaryLight;
  }*/

  static Color dividerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? divider
        : dividerLight;
  }

  static Color borderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? border
        : borderLight;
  }
}

