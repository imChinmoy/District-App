import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/booking_model.dart';

class BookingService {
  static final _db = FirebaseFirestore.instance.collection('Bookings');

  Future<void> bookItem(String type, String itemId, String userId, Map<String, dynamic> bookingData) async {
    await _db.add({
      'type': type,
      'itemId': itemId,
      'userId': userId,
      'data': bookingData,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateBooking(String bookingId, Map<String, dynamic> updatedData) async {
    await _db.doc(bookingId).update({
      'data': updatedData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelBooking(String bookingId) async {
    await _db.doc(bookingId).delete();
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    final snapshot = await _db.where('userId', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => BookingModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<BookingModel?> getBookingById(String bookingId) async {
    final doc = await _db.doc(bookingId).get();
    return doc.exists ? BookingModel.fromMap(doc.data()!, doc.id) : null;
  }
}
