import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../core/utils/result.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/product_providers.dart';
import '../../../../widgets/amazon_app_bar.dart';
import '../../../../widgets/amazon_bottom_nav_bar.dart';
import '../../../../widgets/amazon_button.dart';
import '../../../../widgets/carousel_slider_widget.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cartResult = ref.watch(cartProvider);
    final productAsync = ref.watch(productByIdProvider(widget.productId));
    final cartItemCount = cartResult.fold(
      onSuccess: (cart) => cart.itemCount,
      onError: (_) => 0,
    );
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AmazonAppBar(
        showSearchBar: false,
        cartItemCount: cartItemCount,
      ),
      body: productAsync.when(
        data: (result) => result.fold(
          onSuccess: (product) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductImages(product),
                _buildProductInfo(product),
                _buildPriceSection(product),
                _buildQuantitySelector(),
                _buildActionButtons(product),
                _buildDivider(),
                _buildProductDescription(product),
                _buildDivider(),
                _buildProductSpecifications(product),
                _buildDivider(),
                _buildCustomerReviews(product),
                _buildDivider(),
                _buildSimilarProducts(product),
                const SizedBox(height: 100),
              ],
            ),
          ),
          onError: (failure) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('error'.tr() + ': ${failure.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(productByIdProvider(widget.productId)),
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
      bottomSheet: productAsync.maybeWhen(
        data: (result) => result.fold(
          onSuccess: (product) => _buildBottomActionBar(product),
          onError: (_) => null,
        ),
        orElse: () => null,
      ),
    );
  }

  Widget _buildProductImages(ProductEntity product) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          CarouselSliderWidget(
            height: 300,
            autoPlay: false,
            // viewportFraction: 1.0,
            onPageChanged: (index) {
              setState(() {
                _selectedImageIndex = index;
              });
            },
            imageUrls: product.imageUrls.map((imageUrl) {
              return imageUrl;
            }).toList(),
          ),
          if (product.imageUrls.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: product.imageUrls.asMap().entries.map((entry) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selectedImageIndex == entry.key
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductInfo(ProductEntity product) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.title,
            style: AppTextStyles.heading,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              RatingBar.builder(
                initialRating: product.rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 16,
                ignoreGestures: true,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: AppColors.rating,
                ),
                onRatingUpdate: (rating) {},
              ),
              const SizedBox(width: 8),
              Text(
                '${product.rating} (${product.reviewCount} reviews)',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (product.isPrime)
            Image.network(
              'https://m.media-amazon.com/images/G/01/prime/marketing/slashPrime/amazon-prime-delivery-checkmark._CB659998231_.png',
              height: 20,
            ),
          const SizedBox(height: 8),
          Text(
            'Sold by: ${product.sellerName}',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(ProductEntity product) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: AppTextStyles.priceText,
              ),
              if (product.originalPrice != null) ...[
                Text(
                  '\$${product.originalPrice!.toStringAsFixed(2)}',
                  style: AppTextStyles.originalPriceText,
                ),
                const SizedBox(width: 8),
                Text(
                  '-${((product.originalPrice! - product.price) / product.originalPrice! * 100).toInt()}% off',
                  style: AppTextStyles.dealText,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (product.isPrime)
            Row(
              children: [
                const Icon(Icons.local_shipping, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  'FREE Prime Delivery',
                  style: AppTextStyles.primeText,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Row(
        children: [
          Text('${'quantity'.tr()}:', style: AppTextStyles.bodyMedium),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 16),
                  onPressed: _quantity > 1
                      ? () {
                          setState(() {
                            _quantity--;
                          });
                        }
                      : null,
                ),
                Text('$_quantity', style: AppTextStyles.bodyMedium),
                IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: _quantity < 10
                      ? () {
                          setState(() {
                            _quantity++;
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ProductEntity product) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Column(
        children: [
          AmazonButton(
            text: 'Add to Cart',
            onPressed: () {
              final cartNotifier = ref.read(cartProvider.notifier);
              cartNotifier.addItem(product, quantity: _quantity);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$_quantity ${_quantity > 1 ? 'items'.tr() : 'item'.tr()} ${'item_added_to_cart'.tr()}'),
                  duration: const Duration(seconds: 1),
                  action: SnackBarAction(
                    label: 'VIEW CART',
                    onPressed: () {
                      Navigator.pushNamed(context, '/cart');
                    },
                  ),
                ),
              );
            },
            buttonType: AmazonButtonType.primary,
            isFullWidth: true,
          ),
          const SizedBox(height: 8),
          AmazonButton(
            text: 'Buy Now',
            onPressed: () {
              // Buy now logic
            },
            buttonType: AmazonButtonType.secondary,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProductDescription(ProductEntity product) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('about_this_item'.tr(), style: AppTextStyles.heading),
          const SizedBox(height: 8),
          Text(
            product.description,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildProductSpecifications(ProductEntity product) {
    // Mock specifications
    final Map<String, String> specifications = {
      'Brand': product.sellerName,
      'Model': 'Model ${product.id}',
      'Color': 'Various',
      'Material': 'Premium Quality',
      'Dimensions': '10 x 5 x 2 inches',
      'Weight': '0.5 pounds',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('product_specifications'.tr(), style: AppTextStyles.heading),
          const SizedBox(height: 16),
          ...specifications.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      entry.key,
                      style: AppTextStyles.bodyMediumBold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCustomerReviews(ProductEntity product) {
    // Mock reviews
    final List<Map<String, dynamic>> reviews = [
      {
        'name': 'John Doe',
        'rating': 5.0,
        'date': 'June 15, 2023',
        'title': 'Excellent product!',
        'comment': 'This is one of the best products I have ever purchased. Highly recommended!',
        'helpful': 42,
      },
      {
        'name': 'Jane Smith',
        'rating': 4.0,
        'date': 'May 22, 2023',
        'title': 'Good but could be better',
        'comment': 'The product is good overall, but there are a few minor issues that could be improved.',
        'helpful': 18,
      },
      {
        'name': 'Robert Johnson',
        'rating': 5.0,
        'date': 'April 10, 2023',
        'title': 'Perfect!',
        'comment': 'Exactly what I was looking for. Fast delivery and great quality.',
        'helpful': 31,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('customer_reviews'.tr(), style: AppTextStyles.heading),
              TextButton(
                onPressed: () {
                  // Navigate to all reviews
                },
                child: Text(
                  'See all',
                  style: AppTextStyles.link,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              RatingBar.builder(
                initialRating: product.rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 16,
                ignoreGestures: true,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: AppColors.rating,
                ),
                onRatingUpdate: (rating) {},
              ),
              const SizedBox(width: 8),
              Text(
                '${product.rating} out of 5',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
          Text(
            '${product.reviewCount} ${'ratings'.tr()}',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 16),
          ...reviews.map((review) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.secondaryLight,
                        child: Icon(Icons.person, color: AppColors.secondaryDark),
                      ),
                      const SizedBox(width: 8),
                      Text(review['name'], style: AppTextStyles.bodyMediumBold),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      RatingBar.builder(
                        initialRating: review['rating'],
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 16,
                        ignoreGestures: true,
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: AppColors.rating,
                        ),
                        onRatingUpdate: (rating) {},
                      ),
                      const SizedBox(width: 8),
                      Text(
                        review['title'],
                        style: AppTextStyles.bodyMediumBold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Reviewed on ${review['date']}',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review['comment'],
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${review['helpful']} people found this helpful',
                        style: AppTextStyles.bodySmall,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // Helpful logic
                        },
                        child: Text(
                          'Helpful',
                          style: AppTextStyles.link,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                ],
              ),
            );
          }),
          Center(
            child: TextButton(
              onPressed: () {
                // Navigate to write a review
              },
              child: Text(
                'Write a customer review',
                style: AppTextStyles.link,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarProducts(ProductEntity product) {
    // Get similar products (same category)
    final similarProductsAsync = ref.watch(productsByCategoryProvider(product.category));
    final similarProducts = similarProductsAsync.maybeWhen(
      data: (result) => result.fold(
        onSuccess: (products) => products.where((p) => p.id != product.id).take(5).toList(),
        onError: (_) => <ProductEntity>[],
      ),
      orElse: () => <ProductEntity>[],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('similar_products'.tr(), style: AppTextStyles.heading),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: similarProducts.length,
              itemBuilder: (context, index) {
                final similarProduct = similarProducts[index];
                return Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Image.network(
                          similarProduct.imageUrls.first,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        similarProduct.title,
                        style: AppTextStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${similarProduct.price.toStringAsFixed(2)}',
                        style: AppTextStyles.bodyMediumBold,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 8,
      color: AppColors.dividerBackground,
    );
  }

  Widget _buildBottomActionBar(ProductEntity product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: AmazonButton(
              text: 'Add to Cart',
              onPressed: () {
                final cartNotifier = ref.read(cartProvider.notifier);
                cartNotifier.addItem(product, quantity: _quantity);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$_quantity ${_quantity > 1 ? 'items'.tr() : 'item'.tr()} ${'item_added_to_cart'.tr()}'),
                    duration: const Duration(seconds: 1),
                    action: SnackBarAction(
                      label: 'VIEW CART',
                      onPressed: () {
                        Navigator.pushNamed(context, '/cart');
                      },
                    ),
                  ),
                );
              },
              buttonType: AmazonButtonType.primary,
              isFullWidth: true,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AmazonButton(
              text: 'Buy Now',
              onPressed: () {
                final cartNotifier = ref.read(cartProvider.notifier);
                cartNotifier.addItem(product, quantity: _quantity);
                Navigator.pushNamed(context, '/cart');
              },
              buttonType: AmazonButtonType.secondary,
              isFullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}