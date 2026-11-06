enum NotificationType {
  expenseAdded,
  activityAdded,
  memberJoined,
}

class NotificationEntity {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String tripId;
  final String actorId;
  final DateTime createdAt;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.tripId,
    required this.actorId,
    required this.createdAt,
    this.isRead = false,
  });

  NotificationEntity copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    String? tripId,
    String? actorId,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      tripId: tripId ?? this.tripId,
      actorId: actorId ?? this.actorId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
