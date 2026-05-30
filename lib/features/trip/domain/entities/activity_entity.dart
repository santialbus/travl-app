class ActivityEntity {
  final String id;
  final String tripId;
  final String dayId;
  final String title;
  final ActivityType type;
  final String? description;
  final DateTime? time;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final String? mapsUrl;
  final bool isCompleted;
  final int orderIndex;
  final String createdBy;
  final DateTime createdAt;

  // ✅ Campos extra por tipo
  final String? flightNumber;      // ✈️ IB3456
  final String? trainNumber;       // 🚆 AVE02145
  final String? transportCompany;  // 🚆 Renfe, Blablacar...
  final String? bookingReference;  // 🏨 #ABC123456
  final String? bookingUrl;        // 🏨 https://booking.com/...

  const ActivityEntity({
    required this.id,
    required this.tripId,
    required this.dayId,
    required this.title,
    required this.type,
    this.description,
    this.time,
    this.locationName,
    this.latitude,
    this.longitude,
    this.mapsUrl,
    required this.isCompleted,
    required this.orderIndex,
    required this.createdBy,
    required this.createdAt,
    this.flightNumber,
    this.trainNumber,
    this.transportCompany,
    this.bookingReference,
    this.bookingUrl,
  });

  String get emoji => type.emoji;
  String get typeName => type.name;
}

enum ActivityType {
  flight('flight', '✈️'),
  transport('transport', '🚆'),
  food('food', '🍜'),
  bar('bar', '🍺'),
  place('place', '🌳'),
  hotel('hotel', '🏨'),
  note('note', '📝'),
  expense('expense', '💸');

  final String value;
  final String emoji;

  const ActivityType(this.value, this.emoji);

  static ActivityType fromString(String value) {
    return ActivityType.values.firstWhere(
          (type) => type.value == value,
      orElse: () => ActivityType.note,
    );
  }
}