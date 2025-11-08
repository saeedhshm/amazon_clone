import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../models/product_model.dart';

/// Product remote data source interface
abstract class ProductRemoteDataSource {
  Future<Result<List<ProductModel>>> getAllProducts();
  Future<Result<ProductModel>> getProductById(String productId);
  Future<Result<List<ProductModel>>> getProductsByCategory(String category);
  Future<Result<List<ProductModel>>> searchProducts(String query);
  Future<Result<List<ProductModel>>> getFeaturedProducts();
  Future<Result<List<ProductModel>>> getDealsOfTheDay();
  Future<Result<List<ProductModel>>> getRecommendedProducts();
}

/// Product remote data source implementation (JSON mock data)
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  @override
  Future<Result<List<ProductModel>>> getAllProducts() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/products.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      final products = jsonList
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return Success(products);
    } catch (e) {
      return Error(ServerFailure('Failed to load products: ${e.toString()}'));
    }
  }

  @override
  Future<Result<ProductModel>> getProductById(String productId) async {
    try {
      final result = await getAllProducts();
      return result.fold(
        onSuccess: (products) {
          final product = products.firstWhere(
            (p) => p.id == productId,
            orElse: () => throw Exception('Product not found'),
          );
          return Success(product);
        },
        onError: (failure) => Error(failure),
      );
    } catch (e) {
      return Error(ServerFailure('Failed to load product: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<ProductModel>>> getProductsByCategory(String category) async {
    try {
      final result = await getAllProducts();
      return result.fold(
        onSuccess: (products) {
          final filtered = products.where((p) => p.category == category).toList();
          return Success(filtered);
        },
        onError: (failure) => Error(failure),
      );
    } catch (e) {
      return Error(ServerFailure('Failed to load products by category: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<ProductModel>>> searchProducts(String query) async {
    try {
      final result = await getAllProducts();
      return result.fold(
        onSuccess: (products) {
          final lowerQuery = query.toLowerCase();
          final filtered = products.where((p) {
            return p.title.toLowerCase().contains(lowerQuery) ||
                p.description.toLowerCase().contains(lowerQuery) ||
                p.category.toLowerCase().contains(lowerQuery);
          }).toList();
          return Success(filtered);
        },
        onError: (failure) => Error(failure),
      );
    } catch (e) {
      return Error(ServerFailure('Failed to search products: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<ProductModel>>> getFeaturedProducts() async {
    try {
      final result = await getAllProducts();
      return result.fold(
        onSuccess: (products) {
          // Return top rated products as featured
          final featured = products.toList()
            ..sort((a, b) => b.rating.compareTo(a.rating));
          return Success(featured.take(10).toList());
        },
        onError: (failure) => Error(failure),
      );
    } catch (e) {
      return Error(ServerFailure('Failed to load featured products: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<ProductModel>>> getDealsOfTheDay() async {
    try {
      final result = await getAllProducts();
      return result.fold(
        onSuccess: (products) {
          // Return products with discounts
          final deals = products.where((p) => p.originalPrice != null).toList();
          return Success(deals);
        },
        onError: (failure) => Error(failure),
      );
    } catch (e) {
      return Error(ServerFailure('Failed to load deals: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<ProductModel>>> getRecommendedProducts() async {
    try {
      final result = await getAllProducts();
      return result.fold(
        onSuccess: (products) {
          // Return top rated products as recommended
          final recommended = products.toList()
            ..sort((a, b) => b.rating.compareTo(a.rating));
          return Success(recommended.take(10).toList());
        },
        onError: (failure) => Error(failure),
      );
    } catch (e) {
      return Error(ServerFailure('Failed to load recommended products: ${e.toString()}'));
    }
  }
}

