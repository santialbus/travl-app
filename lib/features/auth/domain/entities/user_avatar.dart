enum UserAvatarStyle {
  avataaars,
}

class UserAvatar {
  final UserAvatarStyle style;
  final String seed;
  final String backgroundColor;

  const UserAvatar({
    this.style = UserAvatarStyle.avataaars,
    required this.seed,
    this.backgroundColor = 'b6e3f4',
  });

  UserAvatar copyWith({
    UserAvatarStyle? style,
    String? seed,
    String? backgroundColor,
  }) {
    return UserAvatar(
      style: style ?? this.style,
      seed: seed ?? this.seed,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }
}
