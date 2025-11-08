import 'dart:async';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Auth repository implementation (mock)
class AuthRepositoryImpl implements AuthRepository {
  AuthEntity? _currentAuth;
  final _authController = StreamController<Result<AuthEntity>>.broadcast();

  AuthRepositoryImpl() {
    // Initialize with unauthenticated state
    _currentAuth = const AuthEntity();
    _authController.add(Success(_currentAuth!));
  }

  @override
  Future<Result<AuthEntity>> signInWithEmailAndPassword(String email, String password) async {
    // Mock authentication - accept any email/password
    await Future.delayed(const Duration(seconds: 1));
    _currentAuth = AuthEntity(
      userId: 'mock-user-id',
      isAuthenticated: true,
    );
    _authController.add(Success(_currentAuth!));
    return Success(_currentAuth!);
  }

  @override
  Future<Result<AuthEntity>> registerWithEmailAndPassword(String name, String email, String password) async {
    // Mock registration
    await Future.delayed(const Duration(seconds: 1));
    _currentAuth = AuthEntity(
      userId: 'mock-user-id',
      isAuthenticated: true,
    );
    _authController.add(Success(_currentAuth!));
    return Success(_currentAuth!);
  }

  @override
  Future<Result<void>> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentAuth = const AuthEntity();
    _authController.add(Success(_currentAuth!));
    return const Success(null);
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    // Mock password reset
    await Future.delayed(const Duration(seconds: 1));
    return const Success(null);
  }

  @override
  Stream<Result<AuthEntity>> get authStateChanges => _authController.stream;

  @override
  Result<AuthEntity> get currentUser {
    if (_currentAuth == null) {
      return Error(AuthFailure('No current user'));
    }
    return Success(_currentAuth!);
  }

  void dispose() {
    _authController.close();
  }
}

