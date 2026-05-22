import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/day_entity.dart';

class DayModel extends DayEntity {
  const DayModel({
    required super.id,
    required super.tripId,
    required super.date,
    required super.title,
    required super.dayNumber,
  });

  factory DayModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return DayModel(
      id: doc.id,
      tripId: data['tripId'] as String,
      date: (data['date'] as Timestamp).toDate(),
      title: data['title'] as String,
      dayNumber: data['dayNumber'] as int,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'tripId': tripId,
      'date': Timestamp.fromDate(date),
      'title': title,
      'dayNumber': dayNumber,
    };
  }
}