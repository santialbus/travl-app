class TripEntity {
  final String id;
  final String name;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String ownerId;
  final List<MemberEntity> members;
  final String inviteCode;
  final String? coverImage;
  final DateTime createdAt;

  const TripEntity({
    required this.id,
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.ownerId,
    required this.members,
    required this.inviteCode,
    this.coverImage,
    required this.createdAt,
  });

  int get numberOfDays {
    return endDate.difference(startDate).inDays + 1;
  }

  bool isOwner(String userId) => ownerId == userId;

  bool isMember(String userId) {
    return members.any((member) => member.userId == userId);
  }
}

class MemberEntity {
  final String userId;
  final String role; // 'host' or 'member'
  final DateTime joinedAt;

  const MemberEntity({
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  bool get isHost => role == 'host';
}