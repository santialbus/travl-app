import 'user_avatar.dart';

class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final UserAvatar? avatar;
  final List<String> tripsOwned;
  final List<String> tripsJoined;
  final DateTime createdAt;
  final String preferredCurrency;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.avatar,
    required this.tripsOwned,
    required this.tripsJoined,
    required this.createdAt,
    required this.preferredCurrency,
  });
}
