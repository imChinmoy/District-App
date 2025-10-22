import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/booking_model.dart';

class BookingCRUD {
  static final _db = FirebaseFirestore.instance.collection('bookings');

  static Future<void> createBooking(BookingModel booking) async {
    await _db.doc(booking.id).set(booking.toMap());
  }

  static Future<void> updateBooking(BookingModel booking) async {
    await _db.doc(booking.id).update(booking.toMap());
  }

  static Future<void> deleteBooking(String id) async {
    await _db.doc(id).delete();
  }

  static Future<List<BookingModel>> getUserBookings(String userId) async {
    final snapshot = await _db.where('userId', isEqualTo: userId).get();
    return snapshot.docs
        .map((doc) => BookingModel.fromMap(doc.data()))
        .toList();
  }
}
