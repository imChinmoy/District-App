import 'package:district/database/firebase/booking_crud.dart';
import 'package:district/database/firebase/firestore_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/repository/booking_repo.dart';
import '../database/repository/event_repo.dart';
import '../database/repository/dining_repo.dart';
import '../database/repository/movie_repo.dart';

final firestoreServiceProvider = Provider<AppDatabase>((ref) => AppDatabase());


final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(BookingService());
});


final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(ref.read(firestoreServiceProvider));
});


final diningRepositoryProvider = Provider<DiningRepository>((ref) {
  return DiningRepository(ref.read(firestoreServiceProvider));
});


final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return MovieRepository(ref.read(firestoreServiceProvider));
});
