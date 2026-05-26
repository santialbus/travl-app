class PlaceEntity {
  final String id;
  final String tripId;
  final String name;
  final PlaceCategory category;
  final PlaceStatus status;
  final String? address;
  final String? mapsUrl;
  final String? notes;
  final DateTime createdAt;

  const PlaceEntity({
    required this.id,
    required this.tripId,
    required this.name,
    required this.category,
    required this.status,
    this.address,
    this.mapsUrl,
    this.notes,
    required this.createdAt,
  });
}

enum PlaceCategory {
  restaurant('restaurant', '🍜'),
  bar('bar', '🍺'),
  museum('museum', '🏛'),
  park('park', '🌳'),
  beach('beach', '🏖'),
  shop('shop', '🛍'),
  hotel('hotel', '🏨'),
  other('other', '📍');

  final String value;
  final String emoji;

  const PlaceCategory(this.value, this.emoji);

  static PlaceCategory fromString(String value) {
    return PlaceCategory.values.firstWhere(
          (c) => c.value == value,
      orElse: () => PlaceCategory.other,
    );
  }
}

enum PlaceStatus {
  pending('pending'),
  visited('visited');

  final String value;

  const PlaceStatus(this.value);

  static PlaceStatus fromString(String value) {
    return PlaceStatus.values.firstWhere(
          (s) => s.value == value,
      orElse: () => PlaceStatus.pending,
    );
  }
}