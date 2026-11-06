class ExpenseEntity {
  final String id;
  final String tripId;
  final String title;
  final double amount;
  final String currency;
  final String paidBy;
  final List<String> participants;
  final ExpenseCategory category;
  final DateTime createdAt;
  final bool isSettlement;
  final String? createdBy;

  const ExpenseEntity({
    required this.id,
    required this.tripId,
    required this.title,
    required this.amount,
    required this.currency,
    required this.paidBy,
    required this.participants,
    required this.category,
    required this.createdAt,
    required this.isSettlement,
    this.createdBy,
  });

  double get splitAmount {
    if (participants.isEmpty) return amount;
    return amount / participants.length;
  }
}

enum ExpenseCategory {
  food('food', '🍜'),
  transport('transport', '🚆'),
  accommodation('accommodation', '🏨'),
  activities('activities', '🎡'),
  shopping('shopping', '🛍'),
  other('other', '💸');

  final String value;
  final String emoji;

  const ExpenseCategory(this.value, this.emoji);

  static ExpenseCategory fromString(String value) {
    return ExpenseCategory.values.firstWhere(
      (c) => c.value == value,
      orElse: () => ExpenseCategory.other,
    );
  }
}
