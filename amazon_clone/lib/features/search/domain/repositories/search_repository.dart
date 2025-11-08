import '../../../../core/utils/result.dart';

/// Search repository interface (domain layer)
abstract class SearchRepository {
  /// Get search suggestions
  Future<Result<List<String>>> getSearchSuggestions(String query);
  
  /// Get recent searches
  Result<List<String>> getRecentSearches();
  
  /// Save search query
  Future<Result<void>> saveSearchQuery(String query);
  
  /// Clear recent searches
  Future<Result<void>> clearRecentSearches();
}

