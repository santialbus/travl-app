class DayEntity {
  final String id;
  final String tripId;
  final DateTime date;
  final String title;
  final int dayNumber;

  const DayEntity({
    required this.id,
    required this.tripId,
    required this.date,
    required this.title,
    required this.dayNumber,
  });
}