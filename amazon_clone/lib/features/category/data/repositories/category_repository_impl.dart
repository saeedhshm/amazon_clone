import '../../../../core/utils/result.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_data_source.dart';

/// Category repository implementation
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<CategoryEntity>>> getAllCategories() async {
    final result = await remoteDataSource.getAllCategories();
    return result.map((models) => models.map((m) => m as CategoryEntity).toList());
  }

  @override
  Future<Result<CategoryEntity>> getCategoryById(String categoryId) async {
    final result = await remoteDataSource.getCategoryById(categoryId);
    return result.map((model) => model as CategoryEntity);
  }
}

