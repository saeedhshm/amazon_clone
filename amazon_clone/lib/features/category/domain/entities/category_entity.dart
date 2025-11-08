/// Category entity (domain layer)
class CategoryEntity {
  final String id;
  final String name;
  final String imageUrl;
  final String? description;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.description,
  });
}

