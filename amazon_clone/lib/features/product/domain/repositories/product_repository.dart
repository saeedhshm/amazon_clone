import '../../../../core/utils/result.dart';
import '../entities/product_entity.dart';

/// Product repository interface (domain layer)
abstract class ProductRepository {
  /// Get all products
  Future<Result<List<ProductEntity>>> getAllProducts();
  
  /// Get product by ID
  Future<Result<ProductEntity>> getProductById(String productId);
  
  /// Get products by category
  Future<Result<List<ProductEntity>>> getProductsByCategory(String category);
  
  /// Search products
  Future<Result<List<ProductEntity>>> searchProducts(String query);
  
  /// Get featured products
  Future<Result<List<ProductEntity>>> getFeaturedProducts();
  
  /// Get deals of the day
  Future<Result<List<ProductEntity>>> getDealsOfTheDay();
  
  /// Get recommended products
  Future<Result<List<ProductEntity>>> getRecommendedProducts();
}

