import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  /// Format date as "Jan 15, 2024"
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format time as "14:30"
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  /// Format datetime as "Jan 15, 2024 14:30"
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }

  /// Get number of days between two dates
  static int daysBetween(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    return endDate.difference(startDate).inDays + 1;
  }

  /// Generate list of days for a trip
  static List<DateTime> generateTripDays(DateTime start, DateTime end) {
    final days = <DateTime>[];
    final numberOfDays = daysBetween(start, end);

    for (int i = 0; i < numberOfDays; i++) {
      days.add(start.add(Duration(days: i)));
    }

    return days;
  }

  /// Check if two dates are the same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Get day title (e.g., "Day 1", "Day 2")
  static String getDayTitle(int dayNumber) {
    return 'Day $dayNumber';
  }

  /// Format date range as "Jan 15 - 20, 2024"
  static String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${DateFormat('MMM dd').format(start)} - ${DateFormat('dd, yyyy').format(end)}';
    } else if (start.year == end.year) {
      return '${DateFormat('MMM dd').format(start)} - ${DateFormat('MMM dd, yyyy').format(end)}';
    } else {
      return '${DateFormat('MMM dd, yyyy').format(start)} - ${DateFormat('MMM dd, yyyy').format(end)}';
    }
  }
}