import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/product_remote_data_source.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

/// Product repository provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final remoteDataSource = ProductRemoteDataSourceImpl();
  return ProductRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// All products provider
final allProductsProvider = FutureProvider<Result<List<ProductEntity>>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return await repository.getAllProducts();
});

/// Product by ID provider
final productByIdProvider = FutureProvider.family<Result<ProductEntity>, String>(
  (ref, productId) async {
    final repository = ref.watch(productRepositoryProvider);
    return await repository.getProductById(productId);
  },
);

/// Products by category provider
final productsByCategoryProvider = FutureProvider.family<Result<List<ProductEntity>>, String>(
  (ref, category) async {
    final repository = ref.watch(productRepositoryProvider);
    return await repository.getProductsByCategory(category);
  },
);

/// Search products provider
final searchProductsProvider = FutureProvider.family<Result<List<ProductEntity>>, String>(
  (ref, query) async {
    final repository = ref.watch(productRepositoryProvider);
    return await repository.searchProducts(query);
  },
);

/// Featured products provider
final featuredProductsProvider = FutureProvider<Result<List<ProductEntity>>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return await repository.getFeaturedProducts();
});

/// Deals of the day provider
final dealsOfTheDayProvider = FutureProvider<Result<List<ProductEntity>>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return await repository.getDealsOfTheDay();
});

/// Recommended products provider
final recommendedProductsProvider = FutureProvider<Result<List<ProductEntity>>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return await repository.getRecommendedProducts();
});

