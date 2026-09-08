class ChecklistItemEntity {
  final String id;
  final String tripId;
  final String title;
  final bool isDone;
  final ChecklistType type;
  final DateTime createdAt;
  final String? assignedTo;

  const ChecklistItemEntity({
    required this.id,
    required this.tripId,
    required this.title,
    required this.isDone,
    required this.type,
    required this.createdAt,
    this.assignedTo,
  });
}

enum ChecklistType {
  preTip('pre-trip', '📋'),
  during('during', '🗺'),
  postTrip('post-trip', '✅');

  final String value;
  final String emoji;

  const ChecklistType(this.value, this.emoji);

  static ChecklistType fromString(String value) {
    return ChecklistType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => ChecklistType.preTip,
    );
  }
}
