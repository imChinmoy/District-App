
enum EventCategory { concert, exhibition, standup, festival }


class EventModel {
  final String id;
  final String name;
  final String description;
  final EventCategory category;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final List<String> images;
  final double rating;
  final int totalReviews;

  EventModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.images,
    required this.rating,
    required this.totalReviews,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category.name,
        'location': location,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'price': price,
        'images': images,
        'rating': rating,
        'totalReviews': totalReviews,
      };

  factory EventModel.fromMap(Map<String, dynamic> map) => EventModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        description: map['description'] ?? '',
        category: EventCategory.values.firstWhere(
          (e) => e.name == map['category'],
          orElse: () => EventCategory.concert,
        ),
        location: map['location'] ?? '',
        startDate: DateTime.parse(map['startDate']),
        endDate: DateTime.parse(map['endDate']),
        price: (map['price'] ?? 0).toDouble(),
        images: List<String>.from(map['images'] ?? []),
        rating: (map['rating'] ?? 0).toDouble(),
        totalReviews: map['totalReviews'] ?? 0,
      );
}
