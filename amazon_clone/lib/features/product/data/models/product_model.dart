import '../../domain/entities/product_entity.dart';

/// Product model (data layer) - extends entity
class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    super.originalPrice,
    required super.imageUrls,
    super.rating,
    super.reviewCount,
    super.isPrime,
    required super.category,
    super.tags,
    super.inStock,
    super.stockQuantity,
    required super.sellerId,
    required super.sellerName,
  });

  /// Create model from JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice'] as num).toDouble()
          : null,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      isPrime: json['isPrime'] ?? false,
      category: json['category'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      inStock: json['inStock'] ?? true,
      stockQuantity: json['stockQuantity'] ?? 0,
      sellerId: json['sellerId'] ?? '',
      sellerName: json['sellerName'] ?? '',
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrls': imageUrls,
      'rating': rating,
      'reviewCount': reviewCount,
      'isPrime': isPrime,
      'category': category,
      'tags': tags,
      'inStock': inStock,
      'stockQuantity': stockQuantity,
      'sellerId': sellerId,
      'sellerName': sellerName,
    };
  }

  /// Convert entity to model
  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      price: entity.price,
      originalPrice: entity.originalPrice,
      imageUrls: entity.imageUrls,
      rating: entity.rating,
      reviewCount: entity.reviewCount,
      isPrime: entity.isPrime,
      category: entity.category,
      tags: entity.tags,
      inStock: entity.inStock,
      stockQuantity: entity.stockQuantity,
      sellerId: entity.sellerId,
      sellerName: entity.sellerName,
    );
  }
}

