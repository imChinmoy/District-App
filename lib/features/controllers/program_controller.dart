import 'package:district/models/event/artist_model.dart';
import 'package:district/models/mood_model.dart';
import 'package:district/providers/program_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:district/database/repository/event_repo.dart';
import 'package:district/database/repository/dining_repo.dart';
import 'package:district/database/repository/movie_repo.dart';
import 'package:district/models/event/event_model.dart';
import 'package:district/models/dining/dining_model.dart';
import 'package:district/models/movie/movie_model.dart';

final eventProvider = FutureProvider<List<EventModel>> ((ref) async {
  final repo = ref.read(eventRepositoryProvider);
  return repo.getAllEvents();
});

final artistProvider = FutureProvider<List<ArtistModel>>((ref) async {
  final repo = ref.read(eventRepositoryProvider);
  return repo.getArtists();
});

final diningProvider = FutureProvider<List<DiningModel>>((ref) async {
  final repo = ref.read(diningRepositoryProvider);
  return repo.getAllDining();
});

final diningTypeProvider = FutureProvider<List<MoodCategory>>((ref) async {
  final repo = ref.read(diningRepositoryProvider);
  return repo.diningType();
});

final movieProvider = FutureProvider<List<MovieModel>>((ref) async {
  final repo = ref.read(movieRepositoryProvider);
  return repo.getAllMovies();
});