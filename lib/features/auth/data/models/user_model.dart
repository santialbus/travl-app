import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../core/constants/firebase_constants.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.photoUrl,
    required super.tripsOwned,
    required super.tripsJoined,
    required super.createdAt,
    required super.preferredCurrency,
  });

  // From Firebase Auth User
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
      tripsOwned: [],
      tripsJoined: [],
      createdAt: DateTime.now(),
      preferredCurrency: 'EUR',
    );
  }

  // From Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      name: data[FirebaseConstants.userNameField] ?? '',
      email: data[FirebaseConstants.userEmailField] ?? '',
      photoUrl: data[FirebaseConstants.userPhotoUrlField],
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

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      FirebaseConstants.userIdField: id,
      FirebaseConstants.userNameField: name,
      FirebaseConstants.userEmailField: email,
      FirebaseConstants.userPhotoUrlField: photoUrl,
      FirebaseConstants.userTripsOwnedField: tripsOwned,
      FirebaseConstants.userTripsJoinedField: tripsJoined,
      FirebaseConstants.userCreatedAtField: Timestamp.fromDate(createdAt),
      FirebaseConstants.userPreferredCurrencyField: preferredCurrency,
    };
  }

  // Copy with
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
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
      tripsOwned: tripsOwned ?? this.tripsOwned,
      tripsJoined: tripsJoined ?? this.tripsJoined,
      createdAt: createdAt ?? this.createdAt,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
    );
  }
}
