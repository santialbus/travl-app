import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travl/features/auth/domain/entities/user_avatar.dart';
import '../../../../core/constants/firebase_constants.dart';

final userAvatarProvider =
    FutureProvider.family<UserAvatar?, String>((ref, userId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    final avatarData = data[FirebaseConstants.userAvatarField];

    if (avatarData == null) return null;

    final avatar = Map<String, dynamic>.from(avatarData as Map);

    return UserAvatar(
      style: UserAvatarStyle.values.firstWhere(
        (style) => style.name == avatar['style'],
        orElse: () => UserAvatarStyle.avataaars,
      ),
      seed: avatar['seed'] as String,
    );
  } catch (e) {
    return null;
  }
});
