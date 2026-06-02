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

class MemberPermissions {
  final bool canAddActivities;
  final bool canEditActivities;
  final bool canDeleteActivities;
  final bool canAddExpenses;
  final bool canAddChecklistItems;

  const MemberPermissions({
    this.canAddActivities = true,
    this.canEditActivities = true,
    this.canDeleteActivities = false,
    this.canAddExpenses = true,
    this.canAddChecklistItems = true,
  });

  // Default permissions para nuevos miembros
  factory MemberPermissions.defaultMember() {
    return const MemberPermissions(
      canAddActivities: true,
      canEditActivities: true,
      canDeleteActivities: false,
      canAddExpenses: true,
      canAddChecklistItems: true,
    );
  }

  // Sin permisos (solo lectura)
  factory MemberPermissions.viewOnly() {
    return const MemberPermissions(
      canAddActivities: false,
      canEditActivities: false,
      canDeleteActivities: false,
      canAddExpenses: false,
      canAddChecklistItems: false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'canAddActivities': canAddActivities,
      'canEditActivities': canEditActivities,
      'canDeleteActivities': canDeleteActivities,
      'canAddExpenses': canAddExpenses,
      'canAddChecklistItems': canAddChecklistItems,
    };
  }

  factory MemberPermissions.fromMap(Map<String, dynamic> map) {
    return MemberPermissions(
      canAddActivities: map['canAddActivities'] as bool? ?? true,
      canEditActivities: map['canEditActivities'] as bool? ?? true,
      canDeleteActivities: map['canDeleteActivities'] as bool? ?? false,
      canAddExpenses: map['canAddExpenses'] as bool? ?? true,
      canAddChecklistItems: map['canAddChecklistItems'] as bool? ?? true,
    );
  }

  MemberPermissions copyWith({
    bool? canAddActivities,
    bool? canEditActivities,
    bool? canDeleteActivities,
    bool? canAddExpenses,
    bool? canAddChecklistItems,
  }) {
    return MemberPermissions(
      canAddActivities: canAddActivities ?? this.canAddActivities,
      canEditActivities: canEditActivities ?? this.canEditActivities,
      canDeleteActivities: canDeleteActivities ?? this.canDeleteActivities,
      canAddExpenses: canAddExpenses ?? this.canAddExpenses,
      canAddChecklistItems: canAddChecklistItems ?? this.canAddChecklistItems,
    );
  }
}

class MemberEntity {
  final String userId;
  final String role; // 'host' | 'cohost' | 'member'
  final DateTime joinedAt;

  const MemberEntity({
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  bool get isHost => role == 'host';
  bool get isCoHost => role == 'cohost';
  bool get isMember => role == 'member';

  // ✅ Permisos simples
  bool get canAddActivities => true; // todos pueden
  bool get canEditActivities => isHost || isCoHost;
  bool get canDeleteActivities => isHost || isCoHost;
  bool get canAddExpenses => true; // todos pueden
  bool get canAddChecklistItems => true; // todos pueden
  bool get canInviteMembers => isHost || isCoHost;
  bool get canDeleteTrip => isHost; // solo host
  bool get canManageRoles => isHost; // solo host
}