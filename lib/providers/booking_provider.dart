import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:district/database/repository/booking_repo.dart';
import 'package:district/database/firebase/booking_crud.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(BookingService());
});