import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/user_remote_data_source.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';

/// User repository provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final remoteDataSource = UserRemoteDataSourceImpl();
  return UserRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Current user provider
final currentUserProvider = FutureProvider<Result<UserEntity>>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return await repository.getUserData();
});

