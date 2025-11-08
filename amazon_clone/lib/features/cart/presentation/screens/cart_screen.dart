import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../core/utils/result.dart';
import '../providers/cart_providers.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../../../widgets/amazon_app_bar.dart';
import '../../../../widgets/amazon_bottom_nav_bar.dart';
import '../../../../widgets/amazon_button.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartResult = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AmazonAppBar(
        showSearchBar: true,
        title: 'cart'.tr(),
        cartItemCount: cartResult.fold(
          onSuccess: (cart) => cart.itemCount,
          onError: (_) => 0,
        ),
      ),
      body: cartResult.fold(
        onSuccess: (cart) => cart.items.isEmpty 
            ? _buildEmptyCart(context) 
            : _buildCartContent(context, ref, cart),
        onError: (failure) => Center(child: Text('error'.tr() + ': ${failure.message}')),
      ),
      bottomNavigationBar: const AmazonBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildCartContent(BuildContext context, WidgetRef ref, CartEntity cart) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return _buildCartItem(context, ref, item);
            },
          ),
        ),
        _buildCartSummary(context, cart),
      ],
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: AppColors.secondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'your_amazon_cart_is_empty'.tr(),
            style: AppTextStyles.heading1,
          ),
          const SizedBox(height: 8),
          Text(
            'shop_todays_deals'.tr(),
            style: AppTextStyles.link,
          ),
          const SizedBox(height: 24),
          AmazonButton(
            text: 'continue_shopping'.tr(),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
            buttonType: AmazonButtonType.primary,
            isFullWidth: false,
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, WidgetRef ref, CartItemEntity item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            SizedBox(
              width: 100,
              height: 100,
              child: Image.network(
                item.product.imageUrls.first,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 16),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.title,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.product.price.toStringAsFixed(2)}',
                    style: AppTextStyles.priceRegular,
                  ),
                  if (item.product.isPrime) ...[  
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.check, size: 16, color: AppColors.primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          'prime'.tr(),
                          style: AppTextStyles.primeText,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'in_stock'.tr(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildQuantitySelector(context, ref, item),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).removeItem(item.product.id);
                        },
                        child: Text(
                          'delete'.tr(),
                          style: AppTextStyles.link,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(BuildContext context, WidgetRef ref, CartItemEntity item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<int>(
        value: item.quantity,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down),
        items: List.generate(10, (index) => index + 1)
            .map((qty) => DropdownMenuItem<int>(
                  value: qty,
                  child: Text('${'quantity'.tr()}: $qty'),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            ref.read(cartProvider.notifier).updateQuantity(item.product.id, value);
          }
        },
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, CartEntity cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'subtotal'.tr()} (${cart.itemCount} items):',
                style: AppTextStyles.bodyMedium,
              ),
              Text(
                '\$${cart.totalAmount.toStringAsFixed(2)}',
                style: AppTextStyles.heading1,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'shipping'.tr() + ':',
                style: AppTextStyles.bodyMedium,
              ),
              Text(
                cart.shippingCost == 0
                    ? 'free_shipping'.tr()
                    : '\$${cart.shippingCost.toStringAsFixed(2)}',
                style: cart.shippingCost == 0
                    ? AppTextStyles.bodyMedium.copyWith(color: AppColors.success)
                    : AppTextStyles.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'tax'.tr() + ':',
                style: AppTextStyles.bodyMedium,
              ),
              Text(
                '\$${cart.tax.toStringAsFixed(2)}',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'grand_total'.tr() + ':',
                style: AppTextStyles.bodyMedium,
              ),
              Text(
                '\$${cart.grandTotal.toStringAsFixed(2)}',
                style: AppTextStyles.heading1,
              ),
            ],
          ),
          const SizedBox(height: 16),
          AmazonButton(
            text: '${'checkout'.tr()} (${cart.itemCount} ${'items'.tr()})',
            onPressed: () {
              Navigator.pushNamed(context, '/checkout');
            },
            buttonType: AmazonButtonType.primary,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}
