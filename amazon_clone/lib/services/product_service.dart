import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/product/data/models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all products
  Future<List<ProductModel>> getAllProducts() async {
    try {
      // In a real app, we would fetch data from Firebase
      // For now, we'll return mock data synchronously
      return Future.value(getMockProducts());
    } catch (e) {
      print('Error getting all products: $e');
      return [];
    }
  }

  // Get products by category
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Search products
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      // This is a simple implementation. In a real app, you might want to use
      // a more sophisticated search solution like Algolia or ElasticSearch
      final snapshot = await _firestore.collection('products').get();
      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()))
          .toList();

      return products.where((product) {
        final title = product.title.toLowerCase();
        final description = product.description.toLowerCase();
        final searchQuery = query.toLowerCase();

        return title.contains(searchQuery) || description.contains(searchQuery);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get featured products
  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('featured', isEqualTo: true)
          .limit(10)
          .get();
      return snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get deals of the day
  Future<List<ProductModel>> getDealsOfTheDay() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('dealOfTheDay', isEqualTo: true)
          .limit(10)
          .get();
      return snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get recommended products
  Future<List<ProductModel>> getRecommendedProducts() async {
    try {
      // In a real app, this would be based on user preferences
      final snapshot = await _firestore
          .collection('products')
          .orderBy('rating', descending: true)
          .limit(10)
          .get();
      return snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // For demo purposes, let's create a method that returns mock products
  List<ProductModel> getMockProducts() {
    return [
      ProductModel(
        id: '1',
        title: 'Apple iPhone 13 Pro Max (128GB) - Sierra Blue',
        description:
            'Apple iPhone 13 Pro Max with A15 Bionic chip, Pro camera system, and Super Retina XDR display with ProMotion.',
        price: 1099.99,
        originalPrice: 1199.99,
        imageUrls: [
          'https://m.media-amazon.com/images/I/61i8Vjb17SL._AC_SX679_.jpg',
        ],
        rating: 4.8,
        reviewCount: 2546,
        isPrime: true,
        category: 'Electronics',
        tags: ['smartphone', 'apple', 'iphone'],
        sellerId: 'apple',
        sellerName: 'Apple',
      ),
      ProductModel(
        id: '2',
        title: 'Samsung Galaxy S22 Ultra (256GB) - Phantom Black',
        description:
            'Samsung Galaxy S22 Ultra with S Pen, 108MP camera, and Dynamic AMOLED 2X display.',
        price: 1199.99,
        originalPrice: 1299.99,
        imageUrls: [
          'https://m.media-amazon.com/images/I/71PvHfU+pwL._AC_SX679_.jpg',
        ],
        rating: 4.7,
        reviewCount: 1823,
        isPrime: true,
        category: 'Electronics',
        tags: ['smartphone', 'samsung', 'galaxy'],
        sellerId: 'samsung',
        sellerName: 'Samsung Electronics',
      ),
      ProductModel(
        id: '3',
        title: 'Sony WH-1000XM4 Wireless Noise Cancelling Headphones',
        description:
            'Industry-leading noise cancellation with Dual Noise Sensor technology.',
        price: 348.00,
        originalPrice: 399.99,
        imageUrls: [
          'https://m.media-amazon.com/images/I/71o8Q5XJS5L._AC_SX679_.jpg',
        ],
        rating: 4.9,
        reviewCount: 3254,
        isPrime: true,
        category: 'Electronics',
        tags: ['headphones', 'sony', 'wireless'],
        sellerId: 'sony',
        sellerName: 'Sony',
      ),
      ProductModel(
        id: '4',
        title: 'Apple MacBook Pro 16-inch (2021)',
        description:
            'Apple M1 Pro chip, 16GB RAM, 512GB SSD, 16-inch Liquid Retina XDR display.',
        price: 2499.00,
        originalPrice: 2699.00,
        imageUrls: [
          'https://m.media-amazon.com/images/I/61aUBxqc5PL._AC_SX679_.jpg',
        ],
        rating: 4.9,
        reviewCount: 1254,
        isPrime: true,
        category: 'Computers',
        tags: ['laptop', 'apple', 'macbook'],
        sellerId: 'apple',
        sellerName: 'Apple',
      ),
      ProductModel(
        id: '5',
        title: 'Amazon Echo Dot (4th Gen)',
        description:
            'Smart speaker with Alexa | Charcoal',
        price: 49.99,
        originalPrice: 59.99,
        imageUrls: [
          'https://m.media-amazon.com/images/I/714Rq4k05UL._AC_SX679_.jpg',
        ],
        rating: 4.7,
        reviewCount: 5678,
        isPrime: true,
        category: 'Smart Home',
        tags: ['smart speaker', 'amazon', 'alexa'],
        sellerId: 'amazon',
        sellerName: 'Amazon',
      ),
      ProductModel(
        id: '6',
        title: 'Kindle Paperwhite (8GB)',
        description:
            'Now with a 6.8" display and thinner borders, adjustable warm light, up to 10 weeks of battery life.',
        price: 139.99,
        originalPrice: 159.99,
        imageUrls: [
          'https://m.media-amazon.com/images/I/61Ww4abGclL._AC_SX679_.jpg',
        ],
        rating: 4.8,
        reviewCount: 4321,
        isPrime: true,
        category: 'Books & Kindle',
        tags: ['kindle', 'amazon', 'e-reader'],
        sellerId: 'amazon',
        sellerName: 'Amazon',
      ),
      ProductModel(
        id: '7',
        title: 'Instant Pot Duo 7-in-1 Electric Pressure Cooker',
        description:
            '6 Quart, 14 One-Touch Programs',
        price: 99.95,
        originalPrice: 129.99,
        imageUrls: [
          'https://m.media-amazon.com/images/I/71WtwEvYDOS._AC_SX679_.jpg',
        ],
        rating: 4.7,
        reviewCount: 8765,
        isPrime: true,
        category: 'Home & Kitchen',
        tags: ['kitchen', 'appliance', 'pressure cooker'],
        sellerId: 'instantpot',
        sellerName: 'Instant Pot',
      ),
      ProductModel(
        id: '8',
        title: 'Fitbit Charge 5 Advanced Fitness & Health Tracker',
        description:
            'Built-in GPS, Heart Rate Monitor, Sleep Tracking, 7-day Battery',
        price: 149.95,
        originalPrice: 179.95,
        imageUrls: [
          'https://m.media-amazon.com/images/I/61aCRNmK5qL._AC_SX679_.jpg',
        ],
        rating: 4.5,
        reviewCount: 3456,
        isPrime: true,
        category: 'Sports & Outdoors',
        tags: ['fitness', 'tracker', 'fitbit'],
        sellerId: 'fitbit',
        sellerName: 'Fitbit',
      ),
      ProductModel(
        id: '9',
        title: 'LEGO Star Wars: The Mandalorian The Child',
        description:
            'Buildable Toy, Build Your Own Baby Yoda, 1,073 Pieces',
        price: 79.99,
        originalPrice: 89.99,
        imageUrls: [
          'https://m.media-amazon.com/images/I/71KZrQnmFqL._AC_SX679_.jpg',
        ],
        rating: 4.9,
        reviewCount: 2345,
        isPrime: true,
        category: 'Toys & Games',
        tags: ['lego', 'star wars', 'mandalorian'],
        sellerId: 'lego',
        sellerName: 'LEGO',
      ),
      ProductModel(
        id: '10',
        title: 'Bose QuietComfort 45 Bluetooth Wireless Noise Cancelling Headphones',
        description:
            'Triple Black, Iconic Noise Cancelling Headphones',
        price: 329.00,
        originalPrice: 379.00,
        imageUrls: [
          'https://m.media-amazon.com/images/I/51JbsHSktkL._AC_SX679_.jpg',
        ],
        rating: 4.7,
        reviewCount: 1876,
        isPrime: true,
        category: 'Electronics',
        tags: ['headphones', 'bose', 'noise cancelling'],
        sellerId: 'bose',
        sellerName: 'Bose',
      ),
    ];
  }

  // Get mock categories
  List<String> getMockCategories() {
    return [
      'Electronics',
      'Computers',
      'Smart Home',
      'Books & Kindle',
      'Home & Kitchen',
      'Sports & Outdoors',
      'Toys & Games',
      'Fashion',
      'Beauty & Personal Care',
      'Grocery',
      'Health & Household',
      'Pet Supplies',
      'Automotive',
      'Baby',
      'Industrial & Scientific',
    ];
  }

  // Get mock deals
  List<ProductModel> getMockDeals() {
    final allProducts = getMockProducts();
    // Return products with discounts
    return allProducts.where((product) => product.originalPrice != null).toList();
  }
}