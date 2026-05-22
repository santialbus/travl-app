import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/trip_entity.dart';
import 'member_model.dart';
import '../../../../core/constants/firebase_constants.dart';

class TripModel extends TripEntity {
  const TripModel({
    required super.id,
    required super.name,
    required super.destination,
    required super.startDate,
    required super.endDate,
    required super.ownerId,
    required super.members,
    required super.inviteCode,
    super.coverImage,
    required super.createdAt,
  });

  factory TripModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TripModel(
      id: doc.id,
      name: data[FirebaseConstants.tripNameField] as String,
      destination: data[FirebaseConstants.tripDestinationField] as String,
      startDate: (data[FirebaseConstants.tripStartDateField] as Timestamp).toDate(),
      endDate: (data[FirebaseConstants.tripEndDateField] as Timestamp).toDate(),
      ownerId: data[FirebaseConstants.tripOwnerIdField] as String,
      members: (data[FirebaseConstants.tripMembersField] as List)
          .map((m) => MemberModel.fromMap(m as Map<String, dynamic>))
          .toList(),
      inviteCode: data[FirebaseConstants.tripInviteCodeField] as String,
      coverImage: data[FirebaseConstants.tripCoverImageField] as String?,
      createdAt: (data[FirebaseConstants.tripCreatedAtField] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FirebaseConstants.tripIdField: id,
      FirebaseConstants.tripNameField: name,
      FirebaseConstants.tripDestinationField: destination,
      FirebaseConstants.tripStartDateField: Timestamp.fromDate(startDate),
      FirebaseConstants.tripEndDateField: Timestamp.fromDate(endDate),
      FirebaseConstants.tripOwnerIdField: ownerId,
      FirebaseConstants.tripMembersField: members
          .map((m) => (m as MemberModel).toMap())
          .toList(),
      FirebaseConstants.tripInviteCodeField: inviteCode,
      FirebaseConstants.tripCoverImageField: coverImage,
      FirebaseConstants.tripCreatedAtField: Timestamp.fromDate(createdAt),
    };
  }

  TripModel copyWith({
    String? id,
    String? name,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? ownerId,
    List<MemberEntity>? members,
    String? inviteCode,
    String? coverImage,
    DateTime? createdAt,
  }) {
    return TripModel(
      id: id ?? this.id,
      name: name ?? this.name,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      ownerId: ownerId ?? this.ownerId,
      members: members ?? this.members,
      inviteCode: inviteCode ?? this.inviteCode,
      coverImage: coverImage ?? this.coverImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}