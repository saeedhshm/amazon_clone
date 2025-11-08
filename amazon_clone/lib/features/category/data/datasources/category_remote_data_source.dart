import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../models/category_model.dart';

/// Category remote data source interface
abstract class CategoryRemoteDataSource {
  Future<Result<List<CategoryModel>>> getAllCategories();
  Future<Result<CategoryModel>> getCategoryById(String categoryId);
}

/// Category remote data source implementation (JSON mock data)
class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  @override
  Future<Result<List<CategoryModel>>> getAllCategories() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/categories.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      final categories = jsonList
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return Success(categories);
    } catch (e) {
      return Error(ServerFailure('Failed to load categories: ${e.toString()}'));
    }
  }

  @override
  Future<Result<CategoryModel>> getCategoryById(String categoryId) async {
    try {
      final result = await getAllCategories();
      return result.fold(
        onSuccess: (categories) {
          final category = categories.firstWhere(
            (c) => c.id == categoryId,
            orElse: () => throw Exception('Category not found'),
          );
          return Success(category);
        },
        onError: (failure) => Error(failure),
      );
    } catch (e) {
      return Error(ServerFailure('Failed to load category: ${e.toString()}'));
    }
  }
}

