import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../models/user_model.dart';

/// User remote data source interface
abstract class UserRemoteDataSource {
  Future<Result<UserModel>> getUserData();
  Future<Result<UserModel>> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  });
  Future<Result<UserModel>> addAddress(String address);
  Future<Result<UserModel>> removeAddress(String address);
  Future<Result<UserModel>> addPaymentMethod(String paymentMethod);
  Future<Result<UserModel>> removePaymentMethod(String paymentMethod);
  Future<Result<UserModel>> updatePrimeStatus(bool isPrime);
}

/// User remote data source implementation (JSON mock data)
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  UserModel? _cachedUser;

  @override
  Future<Result<UserModel>> getUserData() async {
    try {
      if (_cachedUser != null) {
        return Success(_cachedUser!);
      }

      final String jsonString = await rootBundle.loadString('assets/data/users.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      if (jsonList.isEmpty) {
        return Error(ServerFailure('No user data found'));
      }
      final user = UserModel.fromJson(jsonList.first as Map<String, dynamic>);
      _cachedUser = user;
      return Success(user);
    } catch (e) {
      return Error(ServerFailure('Failed to load user data: ${e.toString()}'));
    }
  }

  @override
  Future<Result<UserModel>> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      final result = await getUserData();
      return result.fold(
        onSuccess: (user) {
          final updated = UserModel(
            id: user.id,
            name: name ?? user.name,
            email: user.email,
            phoneNumber: phoneNumber ?? user.phoneNumber,
            profileImageUrl: profileImageUrl ?? user.profileImageUrl,
            addresses: user.addresses,
            paymentMethods: user.paymentMethods,
            isPrime: user.isPrime,
          );
          _cachedUser = updated;
          return Success(updated);
        },
        onError: (failure) => Error(failure),
      );
    } catch (e) {
      return Error(ServerFailure('Failed to update profile: ${e.toString()}'));
    }
  }

  @override
  Future<Result<UserModel>> addAddress(String address) async {
    try {
      final result = await getUserData();
      return result.fold(
        onSuccess: (user) {
          final addresses = List<String>.from(user.addresses)..add(address);
          final updated = UserModel(
            id: user.id,
            name: user.name,
            email: user.email,
            phoneNumber: user.phoneNumber,
            profileImageUrl: user.profileImageUrl,
            addresses: addresses,
            paymentMethods: user.paymentMethods,
            isPrime: user.isPrime,
          );
          _cachedUser = updated;
          return Success(updated);
        },
        onError: (failure) => Error(failure),
      );
    } catch (e) {
      return Error(ServerFailure('Failed to add address: ${e.toString()}'));
    }
  }

  @override
  Future<Result<UserModel>> removeAddress(String address) async {
    try {
      final result = await getUserData();
      return result.fold(
        onSuccess: (user) {
          final addresses = List<String>.from(user.addresses)..remove(address);
          final updated = UserModel(
            id: user.id,
            name: user.name,
            email: user.email,
            phoneNumber: user.phoneNumber,
            profileImageUrl: user.profileImageUrl,
            addresses: addresses,
            paymentMethods: user.paymentMethods,
            isPrime: user.isPrime,
          );
          _cachedUser = updated;
          return Success(updated);
        },
        onError: (failure) => Error(failure),
      );
    } catch (e) {
      return Error(ServerFailure('Failed to remove address: ${e.toString()}'));
    }
  }

  @override
  Future<Result<UserModel>> addPaymentMethod(String paymentMethod) async {
    try {
      final result = await getUserData();
      return result.fold(
        onSuccess: (user) {
          final paymentMethods = List<String>.from(user.paymentMethods)..add(paymentMethod);
          final updated = UserModel(
            id: user.id,
            name: user.name,
            email: user.email,
            phoneNumber: user.phoneNumber,
            profileImageUrl: user.profileImageUrl,
            addresses: user.addresses,
            paymentMethods: paymentMethods,
            isPrime: user.isPrime,
          );
          _cachedUser = updated;
          return Success(updated);
        },
        onError: (failure) => Error(failure),
      );
    } catch (e) {
      return Error(ServerFailure('Failed to add payment method: ${e.toString()}'));
    }
  }

  @override
  Future<Result<UserModel>> removePaymentMethod(String paymentMethod) async {
    try {
      final result = await getUserData();
      return result.fold(
        onSuccess: (user) {
          final paymentMethods = List<String>.from(user.paymentMethods)..remove(paymentMethod);
          final updated = UserModel(
            id: user.id,
            name: user.name,
            email: user.email,
            phoneNumber: user.phoneNumber,
            profileImageUrl: user.profileImageUrl,
            addresses: user.addresses,
            paymentMethods: paymentMethods,
            isPrime: user.isPrime,
          );
          _cachedUser = updated;
          return Success(updated);
        },
        onError: (failure) => Error(failure),
      );
    } catch (e) {
      return Error(ServerFailure('Failed to remove payment method: ${e.toString()}'));
    }
  }

  @override
  Future<Result<UserModel>> updatePrimeStatus(bool isPrime) async {
    try {
      final result = await getUserData();
      return result.fold(
        onSuccess: (user) {
          final updated = UserModel(
            id: user.id,
            name: user.name,
            email: user.email,
            phoneNumber: user.phoneNumber,
            profileImageUrl: user.profileImageUrl,
            addresses: user.addresses,
            paymentMethods: user.paymentMethods,
            isPrime: isPrime,
          );
          _cachedUser = updated;
          return Success(updated);
        },
        onError: (failure) => Error(failure),
      );
    } catch (e) {
      return Error(ServerFailure('Failed to update Prime status: ${e.toString()}'));
    }
  }
}

