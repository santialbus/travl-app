class Validators {
  Validators._();

  /// Validate email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }

    return null;
  }

  /// Validate required field
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate trip name
  static String? tripName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Trip name is required';
    }

    if (value.length > 50) {
      return 'Trip name must be less than 50 characters';
    }

    return null;
  }

  /// Validate destination
  static String? destination(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Destination is required';
    }

    if (value.length > 100) {
      return 'Destination must be less than 100 characters';
    }

    return null;
  }

  /// Validate date range
  static String? dateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      return 'Please select both dates';
    }

    if (end.isBefore(start)) {
      return 'End date must be after start date';
    }

    return null;
  }

  /// Validate amount
  static String? amount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }

    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Enter a valid amount';
    }

    return null;
  }
}