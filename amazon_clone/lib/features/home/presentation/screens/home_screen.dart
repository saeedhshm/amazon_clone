import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../core/utils/result.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../../category/presentation/providers/category_providers.dart';
import '../../../product/presentation/providers/product_providers.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../../widgets/amazon_app_bar.dart';
import '../../../../widgets/amazon_bottom_nav_bar.dart';
import '../../../../widgets/carousel_slider_widget.dart';
import '../../../../widgets/product_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final featuredProductsAsync = ref.watch(featuredProductsProvider);
    final dealsAsync = ref.watch(dealsOfTheDayProvider);
    final recommendedAsync = ref.watch(recommendedProductsProvider);
    final cartResult = ref.watch(cartProvider);
    final cartItemCount = cartResult.fold(
      onSuccess: (cart) => cart.itemCount,
      onError: (_) => 0,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AmazonAppBar(
        showSearchBar: true,
        cartItemCount: cartItemCount,
        onSearchTap: () {
          Navigator.of(context).pushNamed('/search');
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allCategoriesProvider);
          ref.invalidate(featuredProductsProvider);
          ref.invalidate(dealsOfTheDayProvider);
          ref.invalidate(recommendedProductsProvider);
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAddressBar(),
              _buildCarousel(),
              categoriesAsync.when(
                data: (result) => result.fold(
                  onSuccess: (categories) => _buildCategoryGrid(context, categories),
                  onError: (failure) => _buildErrorWidget('error_loading_categories'.tr()),
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => _buildErrorWidget(error.toString()),
              ),
              dealsAsync.when(
                data: (result) => result.fold(
                  onSuccess: (deals) => _buildDealsOfTheDay(context, deals),
                  onError: (failure) => _buildErrorWidget('error_loading_deals'.tr()),
                ),
                loading: () => const SizedBox.shrink(),
                error: (error, stack) => _buildErrorWidget(error.toString()),
              ),
              recommendedAsync.when(
                data: (result) => result.fold(
                  onSuccess: (products) => _buildRecommendedForYou(context, products),
                  onError: (failure) => _buildErrorWidget('error_loading_recommendations'.tr()),
                ),
                loading: () => const SizedBox.shrink(),
                error: (error, stack) => _buildErrorWidget(error.toString()),
              ),
              featuredProductsAsync.when(
                data: (result) => result.fold(
                  onSuccess: (products) => _buildFeaturedProducts(context, products),
                  onError: (failure) => _buildErrorWidget('error_loading_featured'.tr()),
                ),
                loading: () => const SizedBox.shrink(),
                error: (error, stack) => _buildErrorWidget(error.toString()),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AmazonBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        message,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      ),
    );
  }

  Widget _buildAddressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.secondaryLight,
      child: Row(
        children: [
           Icon(Icons.location_on_outlined, color: AppColors.darkText),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${'deliver_to'.tr()} John - New York 10001',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.darkText,
              ),
            ),
          ),
          const Icon(Icons.arrow_drop_down, color: AppColors.darkText),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    final List<String> carouselImages = [
      'https://m.media-amazon.com/images/I/61TD5JLGhIL._SX3000_.jpg',
      'https://m.media-amazon.com/images/I/61jovjd+f9L._SX3000_.jpg',
      'https://m.media-amazon.com/images/I/61DUO0NqyyL._SX3000_.jpg',
      'https://m.media-amazon.com/images/I/71qid7QFWJL._SX3000_.jpg',
    ];

    return CarouselSliderWidget(
      height: 200,
      autoPlay: true,
      // viewportFraction: 1.0,
      imageUrls: carouselImages.map((imageUrl) {
        return imageUrl;
      }).toList(),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, List<CategoryEntity> categories) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('shop_by_category'.tr(), style: AppTextStyles.heading),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.8,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryItem(context, category);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, CategoryEntity category) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/product-listing',
          arguments: {
            'category': category.name,
            'title': category.name,
          },
        );
      },
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                category.imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            category.name,
            style: AppTextStyles.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDealsOfTheDay(BuildContext context, List<ProductEntity> deals) {
    if (deals.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('deals_of_the_day'.tr(), style: AppTextStyles.heading),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/product-listing',
                    arguments: {
                      'title': 'deals_of_the_day'.tr(),
                    },
                  );
                },
                child: Text(
                  'see_all'.tr(),
                  style: AppTextStyles.link,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 320,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: deals.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 200,
                    child: ProductCard(
                      id: deals[index].id,
                      title: deals[index].title,
                      imageUrl: deals[index].imageUrls.first,
                      price: deals[index].price,
                      originalPrice: deals[index].originalPrice,
                      rating: deals[index].rating,
                      reviewCount: deals[index].reviewCount,
                      isPrime: deals[index].isPrime,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedForYou(BuildContext context, List<ProductEntity> products) {
    if (products.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('recommended_for_you'.tr(), style: AppTextStyles.heading),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/product-listing',
                    arguments: {
                      'title': 'recommended_for_you'.tr(),
                    },
                  );
                },
                child: Text(
                  'see_all'.tr(),
                  style: AppTextStyles.link,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 330,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 180,
                    child: ProductCard(
                      id: products[index].id,
                      title: products[index].title,
                      imageUrl: products[index].imageUrls.first,
                      price: products[index].price,
                      originalPrice: products[index].originalPrice,
                      rating: products[index].rating,
                      reviewCount: products[index].reviewCount,
                      isPrime: products[index].isPrime,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProducts(BuildContext context, List<ProductEntity> products) {
    if (products.isEmpty) return const SizedBox.shrink();
    
    final displayCount = products.length > 4 ? 4 : products.length;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('featured_products'.tr(), style: AppTextStyles.heading),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.60,
            ),
            itemCount: displayCount,
            itemBuilder: (context, index) {
              return ProductCard(
                id: products[index].id,
                title: products[index].title,
                imageUrl: products[index].imageUrls.first,
                price: products[index].price,
                originalPrice: products[index].originalPrice,
                rating: products[index].rating,
                reviewCount: products[index].reviewCount,
                isPrime: products[index].isPrime,
              );
            },
          ),
        ],
      ),
    );
  }
}