import 'package:district/models/booking_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/booking_provider.dart';
import '../../database/repository/booking_repo.dart';

final bookingControllerProvider = StateNotifierProvider<BookingController, List<BookingModel>>(
  (ref) => BookingController(ref.read(bookingRepositoryProvider)),
);

class BookingController extends StateNotifier<List<BookingModel>> {
  final BookingRepository _repository;

  BookingController(this._repository) : super([]);

  Future<void> fetchUserBookings(String userId) async {
    state = await _repository.getUserBookings(userId);
  }

  Future<void> addBooking(String type, String itemId, String userId, Map<String, dynamic> data) async {
    await _repository.bookItem(type: type, itemId: itemId, userId: userId, bookingData: data);
    await fetchUserBookings(userId);
  }

  Future<void> updateBooking(String bookingId, Map<String, dynamic> data, String userId) async {
    await _repository.updateBooking(bookingId: bookingId, updatedData: data);
    await fetchUserBookings(userId);
  }

  Future<void> cancelBooking(String bookingId, String userId) async {
    await _repository.cancelBooking(bookingId);
    await fetchUserBookings(userId);
  }
}
