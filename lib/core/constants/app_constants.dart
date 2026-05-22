class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Travl';
  static const String appVersion = '1.0.0';

  // Invite Code
  static const String inviteCodePrefix = 'TRVL-';
  static const int inviteCodeLength = 6;

  // Limits
  static const int maxTripNameLength = 50;
  static const int maxDestinationLength = 100;
  static const int maxActivityTitleLength = 100;
  static const int maxDescriptionLength = 500;

  // Date Format
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'MMM dd, yyyy HH:mm';

  // Activity Types
  static const List<String> activityTypes = [
    'flight',
    'transport',
    'food',
    'bar',
    'place',
    'hotel',
    'note',
    'expense',
  ];

  // Expense Categories
  static const List<String> expenseCategories = [
    'food',
    'transport',
    'accommodation',
    'activities',
    'shopping',
    'other',
  ];

  // Currencies
  static const List<String> currencies = [
    'EUR',
    'USD',
    'GBP',
    'JPY',
    'CNY',
  ];

  static const String defaultCurrency = 'EUR';
}