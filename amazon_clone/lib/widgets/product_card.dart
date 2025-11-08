import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../features/cart/presentation/providers/cart_providers.dart';
import '../features/product/data/models/product_model.dart';

class ProductCard extends ConsumerWidget {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviewCount;
  final bool isPrime;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isPrime = false,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {


    final discountPercentage = originalPrice != null
        ? ((originalPrice! - price) / originalPrice! * 100).round()
        : 0;

    return GestureDetector(
      onTap: onTap ?? () {
        Navigator.pushNamed(
          context,
          '/product-detail',
          arguments: id,
        );
      },
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Center(
                    child: SizedBox(
                      height: 120,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Product Title
                  Text(
                    title,
                    style: AppTextStyles.productTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Rating
                  if (rating > 0)
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: rating,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: AppColors.ratingStarColor,
                          ),
                          itemCount: 5,
                          itemSize: 16.0,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '($reviewCount)',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: originalPrice != null
                            ? AppTextStyles.priceDiscount
                            : AppTextStyles.priceRegular,
                      ),
                      if (originalPrice != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          '\$${originalPrice!.toStringAsFixed(2)}',
                          style: AppTextStyles.priceStrikethrough,
                        ),
                        // const SizedBox(width: 4),

                      ],
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Prime badge
                  if (isPrime)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primeColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text(
                            'Prime',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'FREE Delivery',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),

                  GestureDetector(
                    onTap: onAddToCart ?? () {
                      // Create a product entity from the card data
                      final product = ProductModel(
                        id: id,
                        title: title,
                        description: '',
                        price: price,
                        originalPrice: originalPrice,
                        rating: rating,
                        reviewCount: reviewCount,
                        isPrime: isPrime,
                        imageUrls: [imageUrl],
                        sellerName: 'Amazon',
                        sellerId: 'amazon_official',
                        category: '',
                      );

                      ref.read(cartProvider.notifier).addItem(product);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('item_added_to_cart'.tr()),
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
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.buttonSecondary,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: const Text(
                            'Add to Cart',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Add to Cart button
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: ElevatedButton(
                  //     onPressed: onAddToCart ?? () {
                  //       final cartModel = Provider.of<CartModel>(context, listen: false);
                  //
                  //       // Create a product model from the card data
                  //       final product = ProductModel(
                  //         id: id,
                  //         title: title,
                  //         description: '',
                  //         price: price,
                  //         originalPrice: originalPrice,
                  //         rating: rating,
                  //         reviewCount: reviewCount,
                  //         isPrime: isPrime,
                  //         imageUrls: [imageUrl],
                  //         sellerName: 'Amazon',
                  //         sellerId: 'amazon_official',
                  //         category: '',
                  //       );
                  //
                  //       cartModel.addItem(product);
                  //
                  //       ScaffoldMessenger.of(context).showSnackBar(
                  //         SnackBar(
                  //           content: const Text('Item added to cart'),
                  //           duration: const Duration(seconds: 1),
                  //           action: SnackBarAction(
                  //             label: 'VIEW CART',
                  //             onPressed: () {
                  //               Navigator.pushNamed(context, '/cart');
                  //             },
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: AppColors.buttonSecondary,
                  //       padding: const EdgeInsets.symmetric(vertical: 8),
                  //     ),
                  //     child: const Text(
                  //       'Add to Cart',
                  //       style: TextStyle(
                  //         color: AppColors.textPrimary,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.dealColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '$discountPercentage% off',
                  style: AppTextStyles.dealText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}