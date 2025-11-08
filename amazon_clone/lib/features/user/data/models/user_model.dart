import '../../domain/entities/user_entity.dart';

/// User model (data layer)
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phoneNumber,
    super.profileImageUrl,
    super.addresses,
    super.paymentMethods,
    super.isPrime,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['profileImageUrl'],
      addresses: List<String>.from(json['addresses'] ?? []),
      paymentMethods: List<String>.from(json['paymentMethods'] ?? []),
      isPrime: json['isPrime'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'addresses': addresses,
      'paymentMethods': paymentMethods,
      'isPrime': isPrime,
    };
  }
}

