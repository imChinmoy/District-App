import 'package:district/database/firebase/booking_crud.dart';
import 'package:district/models/booking_model.dart';

class BookingRepository {
  final BookingService _bookingService;

  BookingRepository(this._bookingService);

  Future<void> bookItem({
    required String type,
    required String itemId,
    required String userId,
    required Map<String, dynamic> bookingData,
  }) async {
    await _bookingService.bookItem(type, itemId, userId, bookingData);
  }

  Future<void> updateBooking({
    required String bookingId,
    required Map<String, dynamic> updatedData,
  }) async {
    await _bookingService.updateBooking(bookingId, updatedData);
  }

  Future<void> cancelBooking(String bookingId) async {
    await _bookingService.cancelBooking(bookingId);
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    return await _bookingService.getUserBookings(userId);
  }

  Future<BookingModel?> getBookingById(String bookingId) async {
    return await _bookingService.getBookingById(bookingId);
  }
}
