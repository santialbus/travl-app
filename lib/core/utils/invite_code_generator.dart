import 'dart:math';
import '../constants/app_constants.dart';

class InviteCodeGenerator {
  InviteCodeGenerator._();

  static const String _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static final Random _random = Random();

  /// Generates a unique invite code like "TRVL-8K2M9Q"
  static String generate() {
    final code = List.generate(
      AppConstants.inviteCodeLength,
          (index) => _chars[_random.nextInt(_chars.length)],
    ).join();

    return '${AppConstants.inviteCodePrefix}$code';
  }

  /// Validates invite code format
  static bool isValid(String code) {
    if (!code.startsWith(AppConstants.inviteCodePrefix)) {
      return false;
    }

    final codeWithoutPrefix = code.substring(AppConstants.inviteCodePrefix.length);

    if (codeWithoutPrefix.length != AppConstants.inviteCodeLength) {
      return false;
    }

    return RegExp(r'^[A-Z0-9]+$').hasMatch(codeWithoutPrefix);
  }

  /// Formats user input to uppercase and adds prefix if missing
  static String format(String input) {
    String formatted = input.toUpperCase().trim();

    if (!formatted.startsWith(AppConstants.inviteCodePrefix)) {
      formatted = '${AppConstants.inviteCodePrefix}$formatted';
    }

    return formatted;
  }
}