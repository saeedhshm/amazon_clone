import '../../../../core/utils/result.dart';
import '../entities/category_entity.dart';

/// Category repository interface (domain layer)
abstract class CategoryRepository {
  /// Get all categories
  Future<Result<List<CategoryEntity>>> getAllCategories();
  
  /// Get category by ID
  Future<Result<CategoryEntity>> getCategoryById(String categoryId);
}

