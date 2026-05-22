class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final List<String> tripsOwned;
  final List<String> tripsJoined;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.tripsOwned,
    required this.tripsJoined,
    required this.createdAt,
  });
}