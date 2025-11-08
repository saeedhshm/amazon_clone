/// User entity (domain layer)
class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final List<String> addresses;
  final List<String> paymentMethods;
  final bool isPrime;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    this.addresses = const [],
    this.paymentMethods = const [],
    this.isPrime = false,
  });
}

