import '../../../../core/utils/result.dart';
import '../entities/auth_entity.dart';

/// Auth repository interface (domain layer)
abstract class AuthRepository {
  /// Sign in with email and password
  Future<Result<AuthEntity>> signInWithEmailAndPassword(String email, String password);
  
  /// Register with email and password
  Future<Result<AuthEntity>> registerWithEmailAndPassword(String name, String email, String password);
  
  /// Sign out
  Future<Result<void>> signOut();
  
  /// Reset password
  Future<Result<void>> resetPassword(String email);
  
  /// Get current auth state
  Stream<Result<AuthEntity>> get authStateChanges;
  
  /// Get current user
  Result<AuthEntity> get currentUser;
}

