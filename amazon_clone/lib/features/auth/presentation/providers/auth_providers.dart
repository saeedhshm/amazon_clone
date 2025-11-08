import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/result.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repository = AuthRepositoryImpl();
  ref.onDispose(() {
    // Cleanup if needed
  });
  return repository;
});

/// Auth state stream provider
final authStateProvider = StreamProvider<Result<AuthEntity>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

/// Current user provider
final currentAuthProvider = Provider<Result<AuthEntity>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.currentUser;
});

/// Login state
class LoginState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const LoginState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// Login notifier
class LoginNotifier extends StateNotifier<LoginState> {
  final AuthRepository _repository;

  LoginNotifier(this._repository) : super(const LoginState());

  Future<void> login(String email, String password) async {
    state = const LoginState(isLoading: true);
    
    final result = await _repository.signInWithEmailAndPassword(email, password);
    
    result.fold(
      onSuccess: (_) {
        state = const LoginState(isSuccess: true);
      },
      onError: (failure) {
        state = LoginState(errorMessage: failure.message);
      },
    );
  }

  void reset() {
    state = const LoginState();
  }
}

/// Login provider
final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginNotifier(repository);
});

/// Registration state
class RegistrationState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const RegistrationState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  RegistrationState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return RegistrationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// Registration notifier
class RegistrationNotifier extends StateNotifier<RegistrationState> {
  final AuthRepository _repository;

  RegistrationNotifier(this._repository) : super(const RegistrationState());

  Future<void> register(String name, String email, String password) async {
    state = const RegistrationState(isLoading: true);
    
    final result = await _repository.registerWithEmailAndPassword(name, email, password);
    
    result.fold(
      onSuccess: (_) {
        state = const RegistrationState(isSuccess: true);
      },
      onError: (failure) {
        state = RegistrationState(errorMessage: failure.message);
      },
    );
  }

  void reset() {
    state = const RegistrationState();
  }
}

/// Registration provider
final registrationProvider = StateNotifierProvider<RegistrationNotifier, RegistrationState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegistrationNotifier(repository);
});

/// Password reset state
class PasswordResetState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const PasswordResetState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  PasswordResetState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return PasswordResetState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// Password reset notifier
class PasswordResetNotifier extends StateNotifier<PasswordResetState> {
  final AuthRepository _repository;

  PasswordResetNotifier(this._repository) : super(const PasswordResetState());

  Future<void> resetPassword(String email) async {
    state = const PasswordResetState(isLoading: true);
    
    final result = await _repository.resetPassword(email);
    
    result.fold(
      onSuccess: (_) {
        state = const PasswordResetState(isSuccess: true);
      },
      onError: (failure) {
        state = PasswordResetState(errorMessage: failure.message);
      },
    );
  }

  void reset() {
    state = const PasswordResetState();
  }
}

/// Password reset provider
final passwordResetProvider = StateNotifierProvider<PasswordResetNotifier, PasswordResetState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return PasswordResetNotifier(repository);
});

