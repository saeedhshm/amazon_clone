/// Product entity (domain layer)
class ProductEntity {
  final String id;
  final String title;
  final String description;
  final double price;
  final double? originalPrice;
  final List<String> imageUrls;
  final double rating;
  final int reviewCount;
  final bool isPrime;
  final String category;
  final List<String> tags;
  final bool inStock;
  final int stockQuantity;
  final String sellerId;
  final String sellerName;

  const ProductEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.imageUrls,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isPrime = false,
    required this.category,
    this.tags = const [],
    this.inStock = true,
    this.stockQuantity = 0,
    required this.sellerId,
    required this.sellerName,
  });
}

