enum BookingType { movie, dining, event }

enum BookingStatus { pending, confirmed, cancelled, completed }

class BookingModel {
  final String id;
  final String userId;
  final String itemId;
  final BookingType bookingType;
  final int quantity;
  final double totalPrice;
  final DateTime bookingDate;
  final DateTime createdAt;
  final BookingStatus status;

  BookingModel({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.bookingType,
    required this.quantity,
    required this.totalPrice,
    required this.bookingDate,
    required this.createdAt,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'itemId': itemId,
        'bookingType': bookingType.name,
        'quantity': quantity,
        'totalPrice': totalPrice,
        'bookingDate': bookingDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
      };

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) => BookingModel(
        id: map['id'] ?? '',
        userId: map['userId'] ?? '',
        itemId: map['itemId'] ?? '',
        bookingType: BookingType.values.firstWhere(
          (e) => e.name == map['bookingType'],
          orElse: () => BookingType.event,
        ),
        quantity: map['quantity'] ?? 1,
        totalPrice: (map['totalPrice'] ?? 0).toDouble(),
        bookingDate: DateTime.parse(map['bookingDate']),
        createdAt: DateTime.parse(map['createdAt']),
        status: BookingStatus.values.firstWhere(
          (e) => e.name == map['status'],
          orElse: () => BookingStatus.pending,
        ),
      );
}