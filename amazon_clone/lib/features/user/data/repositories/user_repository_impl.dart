import '../../../../core/utils/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';

/// User repository implementation
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<UserEntity>> getUserData() async {
    final result = await remoteDataSource.getUserData();
    return result.map((model) => model as UserEntity);
  }

  @override
  Future<Result<UserEntity>> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    final result = await remoteDataSource.updateUserProfile(
      name: name,
      phoneNumber: phoneNumber,
      profileImageUrl: profileImageUrl,
    );
    return result.map((model) => model as UserEntity);
  }

  @override
  Future<Result<UserEntity>> addAddress(String address) async {
    final result = await remoteDataSource.addAddress(address);
    return result.map((model) => model as UserEntity);
  }

  @override
  Future<Result<UserEntity>> removeAddress(String address) async {
    final result = await remoteDataSource.removeAddress(address);
    return result.map((model) => model as UserEntity);
  }

  @override
  Future<Result<UserEntity>> addPaymentMethod(String paymentMethod) async {
    final result = await remoteDataSource.addPaymentMethod(paymentMethod);
    return result.map((model) => model as UserEntity);
  }

  @override
  Future<Result<UserEntity>> removePaymentMethod(String paymentMethod) async {
    final result = await remoteDataSource.removePaymentMethod(paymentMethod);
    return result.map((model) => model as UserEntity);
  }

  @override
  Future<Result<UserEntity>> updatePrimeStatus(bool isPrime) async {
    final result = await remoteDataSource.updatePrimeStatus(isPrime);
    return result.map((model) => model as UserEntity);
  }
}

