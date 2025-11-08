import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/result.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';

/// Cart state notifier
class CartNotifier extends StateNotifier<Result<CartEntity>> {
  CartNotifier() : super(Success(const CartEntity()));

  /// Add item to cart
  void addItem(ProductEntity product, {int quantity = 1}) {
    state.fold(
      onSuccess: (cart) {
        final items = List<CartItemEntity>.from(cart.items);
        final existingIndex = items.indexWhere((item) => item.product.id == product.id);

        if (existingIndex >= 0) {
          // Update quantity
          items[existingIndex] = items[existingIndex].copyWith(
            quantity: items[existingIndex].quantity + quantity,
          );
        } else {
          // Add new item
          items.add(CartItemEntity(
            id: DateTime.now().toString() + product.id,
            product: product,
            quantity: quantity,
          ));
        }

        state = Success(CartEntity(items: items));
      },
      onError: (failure) {
        // If error, create new cart
        state = Success(CartEntity(items: [
          CartItemEntity(
            id: DateTime.now().toString() + product.id,
            product: product,
            quantity: quantity,
          ),
        ]));
      },
    );
  }

  /// Remove item from cart
  void removeItem(String productId) {
    state.fold(
      onSuccess: (cart) {
        final items = cart.items.where((item) => item.product.id != productId).toList();
        state = Success(CartEntity(items: items));
      },
      onError: (_) {},
    );
  }

  /// Update item quantity
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    state.fold(
      onSuccess: (cart) {
        final items = cart.items.map((item) {
          if (item.product.id == productId) {
            return item.copyWith(quantity: quantity);
          }
          return item;
        }).toList();
        state = Success(CartEntity(items: items));
      },
      onError: (_) {},
    );
  }

  /// Increase quantity
  void increaseQuantity(String productId) {
    state.fold(
      onSuccess: (cart) {
        final items = cart.items.map((item) {
          if (item.product.id == productId) {
            return item.copyWith(quantity: item.quantity + 1);
          }
          return item;
        }).toList();
        state = Success(CartEntity(items: items));
      },
      onError: (_) {},
    );
  }

  /// Decrease quantity
  void decreaseQuantity(String productId) {
    state.fold(
      onSuccess: (cart) {
        final items = <CartItemEntity>[];
        for (final item in cart.items) {
          if (item.product.id == productId) {
            if (item.quantity > 1) {
              items.add(item.copyWith(quantity: item.quantity - 1));
            }
            // If quantity is 1, don't add it (effectively removes it)
          } else {
            items.add(item);
          }
        }
        state = Success(CartEntity(items: items));
      },
      onError: (_) {},
    );
  }

  /// Clear cart
  void clearCart() {
    state = Success(const CartEntity());
  }

  /// Check if product is in cart
  bool containsProduct(String productId) {
    return state.fold(
      onSuccess: (cart) => cart.items.any((item) => item.product.id == productId),
      onError: (_) => false,
    );
  }
}

/// Cart provider
final cartProvider = StateNotifierProvider<CartNotifier, Result<CartEntity>>((ref) {
  return CartNotifier();
});

