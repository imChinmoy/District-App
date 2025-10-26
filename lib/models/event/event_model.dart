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

  factory EventModel.fromMap(Map<String, dynamic> map) {

    DateTime _safeToDateTime(dynamic data) {
      if (data == null) {
        return DateTime(1970);
      }
      
      if (data.runtimeType.toString() == 'Timestamp' || data.runtimeType.toString() == '_JsonQueryDocumentSnapshotTimestamp') {
        try {
          return data.toDate();
        } catch (_) {
          if (data is String) {
            return DateTime.parse(data);
          }
        }
      }
      if (data is String) {
        return DateTime.parse(data);
      }

      return DateTime(1970); 
    }

    return EventModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: EventCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => EventCategory.concert,
      ),
      location: map['location'] as String? ?? '',
      
      startDate: _safeToDateTime(map['startDate']),
      endDate: _safeToDateTime(map['endDate']),
      
      price: (map['price'] as num? ?? 0).toDouble(),
      images: List<String>.from(map['images'] as List? ?? []),
      rating: (map['rating'] as num? ?? 0).toDouble(),
      totalReviews: map['totalReviews'] as int? ?? 0,
    );
  }
}