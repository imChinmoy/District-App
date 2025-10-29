import 'package:cloud_firestore/cloud_firestore.dart';

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
    'bookingDate': Timestamp.fromDate(bookingDate),
    'createdAt': Timestamp.fromDate(createdAt),
    'status': status.name,
  };

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    final createdAt = map['createdAt'];
    final bookingDate = map['bookingDate'];

    return BookingModel(
      id: map['id'] ?? id,
      userId: map['userId'] ?? '',
      itemId: map['itemId'] ?? '',
      bookingType: BookingType.values.firstWhere(
        (e) => e.name == map['bookingType'],
        orElse: () => BookingType.event,
      ),
      quantity: (map['quantity'] ?? 1) is int
          ? (map['quantity'] ?? 1)
          : int.tryParse(map['quantity'].toString()) ?? 1,
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      bookingDate: _parseDate(bookingDate),
      createdAt: _parseDate(createdAt),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BookingStatus.pending,
      ),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
