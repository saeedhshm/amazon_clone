import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../widgets/amazon_app_bar.dart';
import '../../../../widgets/amazon_bottom_nav_bar.dart';
import '../../../../constants/app_colors.dart';
import '../../../../services/search_service.dart';
import '../../../product/data/models/product_model.dart';
import '../../../../widgets/product_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;
  
  const SearchScreen({super.key, this.initialQuery});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final SearchService _searchService = SearchService();
  final TextEditingController _searchController = TextEditingController();
  
  List<String> _suggestions = [];
  List<ProductModel> _searchResults = [];
  List<String> _recentSearches = [];
  bool _isLoading = false;
  bool _showSuggestions = false;
  
  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery ?? '';
    _recentSearches = _searchService.getRecentSearches();
    
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _performSearch(widget.initialQuery!);
    }
    
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }
    
    // Debounce the search to avoid too many API calls
    // _debounce?.cancel();
    // _debounce = Timer(const Duration(milliseconds: 300), () {
    //   _getSuggestions(_searchController.text);
    // });
  }
  
  
  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _showSuggestions = false;
    });
    
    final results = await _searchService.searchProducts(query);
    
    // Save the search query
    _searchService.saveSearchQuery(query);
    
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }
  
  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    _performSearch(suggestion);
  }
  
  void _onRecentSearchTap(String recentSearch) {
    _searchController.text = recentSearch;
    _performSearch(recentSearch);
  }
  
  void _clearRecentSearches() {
    _searchService.clearRecentSearches();
    setState(() {
      _recentSearches = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AmazonAppBar(
        showSearchBar: false,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _showSuggestions
                ? _buildSuggestions()
                : _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _searchResults.isEmpty && _searchController.text.isEmpty
                        ? _buildRecentSearches()
                        : _searchResults.isEmpty
                            ? _buildNoResults()
                            : _buildSearchResults(),
          ),
        ],
      ),
      bottomNavigationBar: const AmazonBottomNavBar(currentIndex: 0),
    );
  }
  
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      color: AppColors.secondaryColor,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search Amazon',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _suggestions = [];
                              _searchResults = [];
                              _showSuggestions = false;
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _performSearch(value);
                  }
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic, color: Colors.white),
            onPressed: () {
              // Voice search functionality would go here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('voice_search_not_implemented'.tr())),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuggestions() {
    return ListView.builder(
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
        return ListTile(
          leading: const Icon(Icons.search),
          title: Text(suggestion),
          onTap: () => _onSuggestionTap(suggestion),
        );
      },
    );
  }
  
  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return Center(
        child: Text('no_recent_searches'.tr()),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: _clearRecentSearches,
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final recentSearch = _recentSearches[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(recentSearch),
                trailing: const Icon(Icons.north_west),
                onTap: () => _onRecentSearchTap(recentSearch),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No results found for "${_searchController.text}"',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Try checking your spelling or use more general terms',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchResults() {
    return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.6,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final product = _searchResults[index];
            return ProductCard(
              id: product.id,
              title: product.title,
              imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls[0] : '',
              price: product.price,
              originalPrice: product.originalPrice,
              rating: product.rating,
              reviewCount: product.reviewCount,
              isPrime: product.isPrime,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/product-detail',
                  arguments: product.id,
                );
              },
              onAddToCart: () {
                // ProductCard will handle adding to cart via Riverpod
              },
            );
          },
        );
  }
}