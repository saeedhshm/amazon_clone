import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';

/// User repository interface (domain layer)
abstract class UserRepository {
  /// Get current user data
  Future<Result<UserEntity>> getUserData();
  
  /// Update user profile
  Future<Result<UserEntity>> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  });
  
  /// Add address
  Future<Result<UserEntity>> addAddress(String address);
  
  /// Remove address
  Future<Result<UserEntity>> removeAddress(String address);
  
  /// Add payment method
  Future<Result<UserEntity>> addPaymentMethod(String paymentMethod);
  
  /// Remove payment method
  Future<Result<UserEntity>> removePaymentMethod(String paymentMethod);
  
  /// Update Prime status
  Future<Result<UserEntity>> updatePrimeStatus(bool isPrime);
}

