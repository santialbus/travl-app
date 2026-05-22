import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/trip_entity.dart';

class MemberModel extends MemberEntity {
  const MemberModel({
    required super.userId,
    required super.role,
    required super.joinedAt,
  });

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      userId: map['userId'] as String,
      role: map['role'] as String,
      joinedAt: (map['joinedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'role': role,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }

  factory MemberModel.host(String userId) {
    return MemberModel(
      userId: userId,
      role: 'host',
      joinedAt: DateTime.now(),
    );
  }

  factory MemberModel.member(String userId) {
    return MemberModel(
      userId: userId,
      role: 'member',
      joinedAt: DateTime.now(),
    );
  }
}