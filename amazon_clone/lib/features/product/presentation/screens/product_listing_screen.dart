import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/product_providers.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../../widgets/amazon_app_bar.dart';
import '../../../../widgets/amazon_bottom_nav_bar.dart';
import '../../../../widgets/product_card.dart';

class ProductListingScreen extends ConsumerStatefulWidget {
  final String? category;
  final String? searchQuery;
  final String? title;

  const ProductListingScreen({
    super.key,
    this.category,
    this.searchQuery,
    this.title,
  });

  @override
  ConsumerState<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends ConsumerState<ProductListingScreen> {
  List<ProductEntity> _products = [];
  List<ProductEntity> _filteredProducts = [];
  String _sortOption = 'Featured';
  final List<String> _sortOptions = [
    'Featured',
    'Price: Low to High',
    'Price: High to Low',
    'Avg. Customer Review',
    'Newest Arrivals',
  ];

  // Filter options
  final double _minPrice = 0;
  final double _maxPrice = 5000;
  double _selectedMinPrice = 0;
  double _selectedMaxPrice = 5000;
  bool _primeOnly = false;
  double _minRating = 0;
  bool _showFilters = false;


  void _applyFilters() {
    setState(() {
      _filteredProducts = _products.where((product) {
        // Apply price filter
        if (product.price < _selectedMinPrice || product.price > _selectedMaxPrice) {
          return false;
        }

        // Apply Prime filter
        if (_primeOnly && !product.isPrime) {
          return false;
        }

        // Apply rating filter
        if (product.rating < _minRating) {
          return false;
        }

        return true;
      }).toList();

      // Apply sorting
      _applySorting();
    });
  }

  void _applySorting() {
    switch (_sortOption) {
      case 'Price: Low to High':
        _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Avg. Customer Review':
        _filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Newest Arrivals':
        // In a real app, we would sort by date
        // For now, we'll just reverse the list
        _filteredProducts = _filteredProducts.reversed.toList();
        break;
      case 'Featured':
      default:
        // No sorting needed for featured
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartResult = ref.watch(cartProvider);
    final cartItemCount = cartResult.fold(
      onSuccess: (cart) => cart.itemCount,
      onError: (_) => 0,
    );

    // Watch the appropriate provider based on widget parameters
    final productsAsync = widget.category != null
        ? ref.watch(productsByCategoryProvider(widget.category!))
        : widget.searchQuery != null
            ? ref.watch(searchProductsProvider(widget.searchQuery!))
            : ref.watch(allProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AmazonAppBar(
        showSearchBar: true,
        cartItemCount: cartItemCount,
        title: widget.title ?? 'products'.tr(),
      ),
      body: productsAsync.when(
        data: (result) => result.fold(
          onSuccess: (products) {
            if (_products.isEmpty || _products != products) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _products = products;
                  _filteredProducts = List.from(products);
                  _applyFilters();
                });
              });
            }
            return Column(
              children: [
                _buildHeader(),
                _buildSortAndFilterBar(),
                if (_showFilters) _buildFilterPanel(),
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? Center(
                          child: Text('no_products_found'.tr(), style: AppTextStyles.bodyMedium),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            return ProductCard(
                              id: product.id,
                              title: product.title,
                              imageUrl: product.imageUrls.first,
                              price: product.price,
                              originalPrice: product.originalPrice,
                              rating: product.rating,
                              reviewCount: product.reviewCount,
                              isPrime: product.isPrime,
                            );
                          },
                        ),
                ),
              ],
            );
          },
          onError: (failure) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('error'.tr() + ': ${failure.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (widget.category != null) {
                      ref.invalidate(productsByCategoryProvider(widget.category!));
                    } else if (widget.searchQuery != null) {
                      ref.invalidate(searchProductsProvider(widget.searchQuery!));
                    } else {
                      ref.invalidate(allProductsProvider);
                    }
                  },
                  child: Text('retry'.tr()),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('error'.tr() + ': ${error.toString()}'),
        ),
      ),
      bottomNavigationBar: const AmazonBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title ?? widget.category ?? 'Search Results: ${widget.searchQuery}',
              style: AppTextStyles.heading,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${_filteredProducts.length} results',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildSortAndFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.secondaryLight,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                _showSortOptions();
              },
              child: Row(
                children: [
                  const Icon(Icons.sort, size: 18),
                  const SizedBox(width: 4),
                  Text('${'sort'.tr()}: $_sortOption', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ),
          Container(height: 20, width: 1, color: AppColors.divider),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.filter_list, size: 18),
                  const SizedBox(width: 4),
                  Text('filter'.tr(), style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('price_range'.tr(), style: AppTextStyles.bodyMediumBold),
          const SizedBox(height: 8),
          RangeSlider(
            values: RangeValues(_selectedMinPrice, _selectedMaxPrice),
            min: _minPrice,
            max: _maxPrice,
            divisions: 50,
            labels: RangeLabels(
              '\$${_selectedMinPrice.toStringAsFixed(0)}',
              '\$${_selectedMaxPrice.toStringAsFixed(0)}',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _selectedMinPrice = values.start;
                _selectedMaxPrice = values.end;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$${_selectedMinPrice.toStringAsFixed(0)}',
                  style: AppTextStyles.bodySmall),
              Text('\$${_selectedMaxPrice.toStringAsFixed(0)}',
                  style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _primeOnly,
                onChanged: (value) {
                  setState(() {
                    _primeOnly = value ?? false;
                  });
                },
              ),
              Text('prime_only'.tr(), style: AppTextStyles.bodyMedium),
              const SizedBox(width: 4),
              Image.network(
                'https://m.media-amazon.com/images/G/01/prime/marketing/slashPrime/amazon-prime-delivery-checkmark._CB659998231_.png',
                height: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('customer_rating'.tr(), style: AppTextStyles.bodyMediumBold),
          const SizedBox(height: 8),
          Row(
            children: [
              for (int i = 4; i >= 1; i--)
                InkWell(
                  onTap: () {
                    setState(() {
                      _minRating = i.toDouble();
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _minRating == i.toDouble()
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      color: _minRating == i.toDouble()
                          ? AppColors.primaryLight
                          : AppColors.white,
                    ),
                    child: Row(
                      children: [
                        for (int j = 0; j < i; j++)
                          const Icon(Icons.star, color: AppColors.rating, size: 16),
                        for (int j = i; j < 5; j++)
                          const Icon(Icons.star_border, color: AppColors.rating, size: 16),
                        Text('up'.tr()),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedMinPrice = _minPrice;
                    _selectedMaxPrice = _maxPrice;
                    _primeOnly = false;
                    _minRating = 0;
                    _showFilters = false;
                  });
                  _applyFilters();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryLight,
                  foregroundColor: AppColors.darkText,
                ),
                child: Text('clear_all'.tr()),
              ),
              ElevatedButton(
                onPressed: () {
                  _applyFilters();
                  setState(() {
                    _showFilters = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
                child: Text('apply'.tr()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('sort_by'.tr(), style: AppTextStyles.heading),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _sortOptions.length,
                  itemBuilder: (context, index) {
                    final option = _sortOptions[index];
                    return ListTile(
                      title: Text(option),
                      trailing: _sortOption == option
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () {
                        setState(() {
                          _sortOption = option;
                        });
                        _applyFilters();
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}