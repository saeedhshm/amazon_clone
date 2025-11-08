import 'cart_item_entity.dart';

/// Cart entity (domain layer)
class CartEntity {
  final List<CartItemEntity> items;

  const CartEntity({this.items = const []});

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get shippingCost {
    // Free shipping for Prime items or orders over $35
    final hasPrimeItems = items.any((item) => item.product.isPrime);
    if (hasPrimeItems || totalAmount >= 35) {
      return 0.0;
    }
    return 5.99; // Standard shipping cost
  }

  double get tax => totalAmount * 0.08; // 8% tax rate

  double get grandTotal => totalAmount + shippingCost + tax;

  CartEntity copyWith({
    List<CartItemEntity>? items,
  }) {
    return CartEntity(
      items: items ?? this.items,
    );
  }
}

