class ArtistModel {
  final String id;
  final String name;
  final String category;
  final String image;
  final double rating;
  final int upcomingEvents;

  ArtistModel({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.rating,
    required this.upcomingEvents,
  });

  factory ArtistModel.fromMap(Map<String, dynamic> map) => ArtistModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        category: map['category'] ?? '',
        image: map['image'] ?? '',
        rating: (map['rating'] ?? 0).toDouble(),
        upcomingEvents: map['upcomingEvents'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'image': image,
        'rating': rating,
        'upcomingEvents': upcomingEvents,
      };
}
