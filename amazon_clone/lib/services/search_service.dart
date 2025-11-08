import '../features/product/data/models/product_model.dart';
import 'product_service.dart';

class SearchService {
  final ProductService _productService = ProductService();
  
  // Get search suggestions based on query
  Future<List<String>> getSearchSuggestions(String query) async {
    if (query.isEmpty) {
      return [];
    }
    
    // In a real app, we would fetch suggestions from an API
    // For now, we'll filter mock products synchronously
    final products = _productService.getMockProducts();
    
    // Filter products by title or category containing the query
    final filteredProducts = products.where((product) {
      return product.title.toLowerCase().contains(query.toLowerCase()) ||
          (product.category.toLowerCase().contains(query.toLowerCase()));
    }).toList();

    // Extract titles and categories as suggestions
    final suggestions = <String>{};
    for (var product in filteredProducts) {
      suggestions.add(product.title);
      if (product.category.isNotEmpty) {
        suggestions.add(product.category);
      }
    }

    return suggestions.take(5).toList();
  }
  
  // Search products based on query
  Future<List<ProductModel>> searchProducts(String query) async {
    if (query.isEmpty) {
      return [];
    }
    
    // In a real app, we would search products from an API or Firebase
    // For now, we'll filter mock products synchronously
    final products = _productService.getMockProducts();
    
    // Filter products by title or category containing the query
    final filteredProducts = products.where((product) {
      return product.title.toLowerCase().contains(query.toLowerCase()) ||
          (product.category.toLowerCase().contains(query.toLowerCase()));
    }).toList();

    // Save the search query to recent searches
    saveSearchQuery(query);

    return filteredProducts;
  }
  
  // Get recent searches (would normally be stored in local storage or user profile)
  List<String> getRecentSearches() {
    // Mock recent searches
    return [
      'wireless headphones',
      'laptop stand',
      'phone case',
      'kitchen gadgets',
      'running shoes'
    ];
  }
  
  // Save a search query to recent searches
  void saveSearchQuery(String query) {
    // In a real app, this would save to local storage or user profile
    print('Saving search query: $query');
  }
  
  // Clear recent searches
  void clearRecentSearches() {
    // In a real app, this would clear from local storage or user profile
    print('Clearing recent searches');
  }
}