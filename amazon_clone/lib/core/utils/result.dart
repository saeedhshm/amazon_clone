import '../error/failures.dart';

/// Result type for functional error handling
sealed class Result<T> {
  const Result();
}

/// Success result
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// Error result
class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}

/// Extension methods for Result
extension ResultExtensions<T> on Result<T> {
  /// Check if result is success
  bool get isSuccess => this is Success<T>;
  
  /// Check if result is error
  bool get isError => this is Error<T>;
  
  /// Get data if success, null otherwise
  T? get dataOrNull => switch (this) {
    Success<T>(:final data) => data,
    Error<T>() => null,
  };
  
  /// Get failure if error, null otherwise
  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    Error<T>(:final failure) => failure,
  };
  
  /// Map success data
  Result<R> map<R>(R Function(T data) mapper) {
    return switch (this) {
      Success<T>(:final data) => Success(mapper(data)),
      Error<T>(:final failure) => Error<R>(failure),
    };
  }
  
  /// Map error
  Result<T> mapError(Failure Function(Failure failure) mapper) {
    return switch (this) {
      Success<T>(:final data) => Success<T>(data),
      Error<T>(:final failure) => Error<T>(mapper(failure)),
    };
  }
  
  /// Fold result to a single value
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onError,
  }) {
    return switch (this) {
      Success<T>(:final data) => onSuccess(data),
      Error<T>(:final failure) => onError(failure),
    };
  }
}

