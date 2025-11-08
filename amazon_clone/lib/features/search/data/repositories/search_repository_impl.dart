import '../../../../core/utils/result.dart';
import '../../domain/repositories/search_repository.dart';
import '../../../product/domain/repositories/product_repository.dart';

/// Search repository implementation
class SearchRepositoryImpl implements SearchRepository {
  final List<String> _recentSearches = [];
  final ProductRepository productRepository;

  SearchRepositoryImpl({required this.productRepository});

  @override
  Future<Result<List<String>>> getSearchSuggestions(String query) async {
    if (query.isEmpty) {
      return const Success([]);
    }

    try {
      // Use product repository to get suggestions
      final productsResult = await productRepository.searchProducts(query);
      
      return productsResult.fold(
        onSuccess: (products) {
          final suggestions = <String>{};
          for (final product in products) {
            if (product.title.toLowerCase().contains(query.toLowerCase())) {
              suggestions.add(product.title);
            }
            if (product.category.toLowerCase().contains(query.toLowerCase())) {
              suggestions.add(product.category);
            }
          }
          return Success(suggestions.take(5).toList());
        },
        onError: (failure) => const Success([]),
      );
    } catch (e) {
      return const Success([]);
    }
  }

  @override
  Result<List<String>> getRecentSearches() {
    return Success(List<String>.from(_recentSearches));
  }

  @override
  Future<Result<void>> saveSearchQuery(String query) async {
    if (query.isEmpty) {
      return const Success(null);
    }

    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 10) {
      _recentSearches.removeLast();
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> clearRecentSearches() async {
    _recentSearches.clear();
    return const Success(null);
  }
}

