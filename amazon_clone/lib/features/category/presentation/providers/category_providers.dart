import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/category_remote_data_source.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';

/// Category repository provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final remoteDataSource = CategoryRemoteDataSourceImpl();
  return CategoryRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// All categories provider
final allCategoriesProvider = FutureProvider<Result<List<CategoryEntity>>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.getAllCategories();
});

/// Category by ID provider
final categoryByIdProvider = FutureProvider.family<Result<CategoryEntity>, String>(
  (ref, categoryId) async {
    final repository = ref.watch(categoryRepositoryProvider);
    return await repository.getCategoryById(categoryId);
  },
);

