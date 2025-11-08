import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/cart/domain/entities/cart_item_entity.dart';
import '../features/product/data/models/product_model.dart';
import 'product_service.dart';
import 'dart:math' as math;

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ProductService _productService = ProductService();
  
  // Mock data for development purposes
  List<CartItemEntity> getMockCartItems() {
    final productService = ProductService();
    final mockProducts = productService.getMockProducts().take(3).toList();
    final random = math.Random();
    
    return mockProducts.map((product) {
      return CartItemEntity(
        id: DateTime.now().toString() + product.id,
        product: product,
        quantity: random.nextInt(3) + 1,
      );
    }).toList();
  }

  // Get cart reference for current user
  DocumentReference get _cartRef {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('carts').doc(userId);
  }

  // Get cart items for current user
  Future<List<CartItemEntity>> getCartItems() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return [];
      }

      final cartDoc = await _cartRef.get();
      if (!cartDoc.exists) {
        return [];
      }

      final cartData = cartDoc.data() as Map<String, dynamic>;
      final items = cartData['items'] as List<dynamic>;

      final List<CartItemEntity> cartItems = [];
      for (var item in items) {
        final productId = item['productId'] as String;
        final quantity = item['quantity'] as int;

        // In a real app, we would fetch the product from Firestore
        // For now, we'll use mock data
        final product = await _productService.getProductById(productId);
        if (product != null) {
          cartItems.add(
            CartItemEntity(
              id: item['id'] as String,
              product: product,
              quantity: quantity,
            ),
          );
        }
      }

      return cartItems;
    } catch (e) {
      print('Error getting cart items: $e');
      return [];
    }
  }

  // Add item to cart
  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return;
      }

      final cartDoc = await _cartRef.get();
      if (!cartDoc.exists) {
        // Create new cart
        await _cartRef.set({
          'userId': userId,
          'items': [
            {
              'id': DateTime.now().toString(),
              'productId': product.id,
              'quantity': quantity,
            }
          ],
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return;
      }

      // Update existing cart
      final cartData = cartDoc.data() as Map<String, dynamic>;
      final items = List<Map<String, dynamic>>.from(cartData['items'] ?? []);

      // Check if product already in cart
      final existingItemIndex = items.indexWhere((item) => item['productId'] == product.id);

      if (existingItemIndex >= 0) {
        // Update quantity
        items[existingItemIndex]['quantity'] = items[existingItemIndex]['quantity'] + quantity;
      } else {
        // Add new item
        items.add({
          'id': DateTime.now().toString(),
          'productId': product.id,
          'quantity': quantity,
        });
      }

      await _cartRef.update({
        'items': items,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String productId) async {
    try {
      final cartDoc = await _cartRef.get();
      if (!cartDoc.exists) {
        return;
      }

      final cartData = cartDoc.data() as Map<String, dynamic>;
      final items = List<Map<String, dynamic>>.from(cartData['items'] ?? []);

      items.removeWhere((item) => item['productId'] == productId);

      await _cartRef.update({
        'items': items,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  // Update item quantity
  Future<void> updateQuantity(String productId, int quantity) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(productId);
        return;
      }

      final cartDoc = await _cartRef.get();
      if (!cartDoc.exists) {
        return;
      }

      final cartData = cartDoc.data() as Map<String, dynamic>;
      final items = List<Map<String, dynamic>>.from(cartData['items'] ?? []);

      final existingItemIndex = items.indexWhere((item) => item['productId'] == productId);

      if (existingItemIndex >= 0) {
        items[existingItemIndex]['quantity'] = quantity;

        await _cartRef.update({
          'items': items,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    try {
      await _cartRef.update({
        'items': [],
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  // This method was removed to avoid duplication with the one at the top of the file
}