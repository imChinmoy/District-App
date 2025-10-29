
enum FoodCategory { starter, mainCourse, dessert, beverage }

class MenuModel {
  final String id;
  final String name;
  final double price;
  final String description;
  final FoodCategory category;
  final bool isVeg;
  final bool isAvailable;
  final String imageUrl;

  MenuModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.isVeg,
    required this.isAvailable,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'price': price,
        'description': description,
        'category': category.name,
        'isVeg': isVeg,
        'isAvailable': isAvailable,
        'imageUrl': imageUrl,
      };

  factory MenuModel.fromMap(Map<String, dynamic> map) => MenuModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        price: (map['price'] ?? 0).toDouble(),
        category: FoodCategory.values.firstWhere(
          (e) => e.name == map['category'],
          orElse: () => FoodCategory.mainCourse,
        ),
        isVeg: map['isVeg'] ?? false,
        isAvailable: map['isAvailable'] ?? true,
        imageUrl: map['imageUrl'] ?? '', 
        description: map['description'] ?? 'No description available',
      );
}