import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_avatar.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../core/constants/firebase_constants.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.photoUrl,
    super.avatar,
    required super.tripsOwned,
    required super.tripsJoined,
    required super.createdAt,
    required super.preferredCurrency,
  });

  factory UserModel.fromFirebaseUser({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
  }) {
    return UserModel(
      id: uid,
      name: name,
      email: email,
      photoUrl: photoUrl,
      avatar: null,
      tripsOwned: [],
      tripsJoined: [],
      createdAt: DateTime.now(),
      preferredCurrency: 'EUR',
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final avatarData = data[FirebaseConstants.userAvatarField] as Map?;

    return UserModel(
      id: doc.id,
      name: data[FirebaseConstants.userNameField] ?? '',
      email: data[FirebaseConstants.userEmailField] ?? '',
      photoUrl: data[FirebaseConstants.userPhotoUrlField],
      avatar: avatarData == null
          ? null
          : UserAvatar(
              style: UserAvatarStyle.values.firstWhere(
                (style) => style.name == avatarData['style'],
                orElse: () => UserAvatarStyle.avataaars,
              ),
              seed: avatarData['seed'] as String? ?? doc.id,
              backgroundColor:
                  avatarData['backgroundColor'] as String? ?? 'b6e3f4',
            ),
      tripsOwned:
          List<String>.from(data[FirebaseConstants.userTripsOwnedField] ?? []),
      tripsJoined:
          List<String>.from(data[FirebaseConstants.userTripsJoinedField] ?? []),
      createdAt:
          (data[FirebaseConstants.userCreatedAtField] as Timestamp).toDate(),
      preferredCurrency:
          data[FirebaseConstants.userPreferredCurrencyField] ?? 'EUR',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FirebaseConstants.userIdField: id,
      FirebaseConstants.userNameField: name,
      FirebaseConstants.userEmailField: email,
      FirebaseConstants.userPhotoUrlField: photoUrl,
      FirebaseConstants.userAvatarField: avatar == null
          ? null
          : {
              'style': avatar!.style.name,
              'seed': avatar!.seed,
              'backgroundColor': avatar!.backgroundColor,
            },
      FirebaseConstants.userTripsOwnedField: tripsOwned,
      FirebaseConstants.userTripsJoinedField: tripsJoined,
      FirebaseConstants.userCreatedAtField: Timestamp.fromDate(createdAt),
      FirebaseConstants.userPreferredCurrencyField: preferredCurrency,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    UserAvatar? avatar,
    List<String>? tripsOwned,
    List<String>? tripsJoined,
    DateTime? createdAt,
    String? preferredCurrency,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      avatar: avatar ?? this.avatar,
      tripsOwned: tripsOwned ?? this.tripsOwned,
      tripsJoined: tripsJoined ?? this.tripsJoined,
      createdAt: createdAt ?? this.createdAt,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
    );
  }
}
