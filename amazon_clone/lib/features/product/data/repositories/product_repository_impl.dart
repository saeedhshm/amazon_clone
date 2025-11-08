import '../../../../core/utils/result.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

/// Product repository implementation (data layer)
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<ProductEntity>>> getAllProducts() async {
    final result = await remoteDataSource.getAllProducts();
    return result.map((models) => models.map((m) => m as ProductEntity).toList());
  }

  @override
  Future<Result<ProductEntity>> getProductById(String productId) async {
    final result = await remoteDataSource.getProductById(productId);
    return result.map((model) => model as ProductEntity);
  }

  @override
  Future<Result<List<ProductEntity>>> getProductsByCategory(String category) async {
    final result = await remoteDataSource.getProductsByCategory(category);
    return result.map((models) => models.map((m) => m as ProductEntity).toList());
  }

  @override
  Future<Result<List<ProductEntity>>> searchProducts(String query) async {
    final result = await remoteDataSource.searchProducts(query);
    return result.map((models) => models.map((m) => m as ProductEntity).toList());
  }

  @override
  Future<Result<List<ProductEntity>>> getFeaturedProducts() async {
    final result = await remoteDataSource.getFeaturedProducts();
    return result.map((models) => models.map((m) => m as ProductEntity).toList());
  }

  @override
  Future<Result<List<ProductEntity>>> getDealsOfTheDay() async {
    final result = await remoteDataSource.getDealsOfTheDay();
    return result.map((models) => models.map((m) => m as ProductEntity).toList());
  }

  @override
  Future<Result<List<ProductEntity>>> getRecommendedProducts() async {
    final result = await remoteDataSource.getRecommendedProducts();
    return result.map((models) => models.map((m) => m as ProductEntity).toList());
  }
}

