class Validators {
  Validators._();

  /// Validate email
  static String? email(
    String? value, {
    String requiredMessage = 'Email is required',
    String invalidMessage = 'Enter a valid email',
  }) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return requiredMessage;
    }

    // Accepts longer TLDs such as .travel, .technology, etc.
    final emailRegex = RegExp(
      r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@"
      r"[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?"
      r"(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?)+$",
    );

    if (!emailRegex.hasMatch(email)) {
      return invalidMessage;
    }

    return null;
  }

  /// Validate required field
  static String? required(
    String? value,
    String fieldName, {
    String? requiredMessage,
  }) {
    if (value == null || value.trim().isEmpty) {
      return requiredMessage ?? '$fieldName is required';
    }

    return null;
  }

  /// Validate trip name
  static String? tripName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Trip name is required';
    }

    if (value.trim().length > 50) {
      return 'Trip name must be less than 50 characters';
    }

    return null;
  }

  /// Validate destination
  static String? destination(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Destination is required';
    }

    if (value.trim().length > 100) {
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
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }

    final amount = double.tryParse(value.trim());

    if (amount == null || amount <= 0) {
      return 'Enter a valid amount';
    }

    return null;
  }
}
