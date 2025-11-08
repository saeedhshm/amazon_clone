/// Auth entity (domain layer)
class AuthEntity {
  final String? userId;
  final bool isAuthenticated;

  const AuthEntity({
    this.userId,
    this.isAuthenticated = false,
  });

  AuthEntity copyWith({
    String? userId,
    bool? isAuthenticated,
  }) {
    return AuthEntity(
      userId: userId ?? this.userId,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

