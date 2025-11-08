import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/result.dart';
import '../../../product/presentation/providers/product_providers.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../domain/repositories/search_repository.dart';

/// Search repository provider
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final productRepository = ref.watch(productRepositoryProvider);
  return SearchRepositoryImpl(productRepository: productRepository);
});

/// Search suggestions provider
final searchSuggestionsProvider = FutureProvider.family<Result<List<String>>, String>(
  (ref, query) async {
    final repository = ref.watch(searchRepositoryProvider);
    return await repository.getSearchSuggestions(query);
  },
);

/// Recent searches provider
final recentSearchesProvider = Provider<Result<List<String>>>((ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return repository.getRecentSearches();
});

