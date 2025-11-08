import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/category/data/models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all categories
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      return snapshot.docs
          .map((doc) => CategoryModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get category by ID
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      final doc = await _firestore.collection('categories').doc(categoryId).get();
      if (doc.exists) {
        return CategoryModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // For demo purposes, let's create a method that returns mock categories
  List<CategoryModel> getMockCategories() {
    return [
      CategoryModel(
        id: 'electronics',
        name: 'Electronics',
        imageUrl: 'https://m.media-amazon.com/images/I/71bhWgQK-cL._AC_UL320_.jpg',
        description: 'Phones, TVs, laptops, cameras, and more',
      ),
      CategoryModel(
        id: 'computers',
        name: 'Computers',
        imageUrl: 'https://m.media-amazon.com/images/G/42/Egypt-hq/2025/img/Consumer_Electronics/XCM_CUTTLE_2177854_6569847_420x420_en_AE._CB790789115_.jpg',
        description: 'Desktops, laptops, tablets, and accessories',
      ),
      CategoryModel(
        id: 'smart_home',
        name: 'Smart Home',
        imageUrl: 'https://m.media-amazon.com/images/I/617J9n4Ux6L._AC_SX679_.jpg',
        description: 'Smart speakers, displays, and devices',
      ),
      CategoryModel(
        id: 'books',
        name: 'Books & Kindle',
        imageUrl: 'https://m.media-amazon.com/images/I/71c1LRLBTBL._AC_UL320_.jpg',
        description: 'Books, e-readers, and accessories',
      ),
      CategoryModel(
        id: 'home_kitchen',
        name: 'Home & Kitchen',
        imageUrl: 'https://m.media-amazon.com/images/I/71WtwEvYDOS._AC_UL320_.jpg',
        description: 'Furniture, kitchen appliances, and home decor',
      ),
      CategoryModel(
        id: 'sports',
        name: 'Sports & Outdoors',
        imageUrl: 'https://m.media-amazon.com/images/I/61OYl6jafpL._AC_SX679_.jpg',
        description: 'Athletic wear, equipment, and outdoor gear',
      ),
      CategoryModel(
        id: 'toys',
        name: 'Toys & Games',
        imageUrl: 'https://m.media-amazon.com/images/I/61W3yu9wAcL._AC_UL640_FMwebp_QL65_.jpg',
        description: 'Toys, games, and collectibles',
      ),
      CategoryModel(
        id: 'fashion',
        name: 'Fashion',
        imageUrl: 'https://m.media-amazon.com/images/I/71czu7WgGuL._AC_UL320_.jpg',
        description: 'Clothing, shoes, jewelry, and watches',
      ),
      CategoryModel(
        id: 'beauty',
        name: 'Beauty & Personal Care',
        imageUrl: 'https://m.media-amazon.com/images/I/71BzaiYYOuL._AC_UL640_QL65_.jpg',
        description: 'Makeup, skincare, haircare, and fragrances',
      ),
      CategoryModel(
        id: 'grocery',
        name: 'Grocery',
        imageUrl: 'https://m.media-amazon.com/images/I/61h7X5R-JuL._AC_UL640_FMwebp_QL65_.jpg',
        description: 'Food, beverages, and household essentials',
      ),
    ];
  }
}