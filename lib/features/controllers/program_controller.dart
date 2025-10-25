import 'package:district/models/mood_model.dart';
import 'package:district/providers/program_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:district/database/repository/event_repo.dart';
import 'package:district/database/repository/dining_repo.dart';
import 'package:district/database/repository/movie_repo.dart';
import 'package:district/models/event/event_model.dart';
import 'package:district/models/dining/dining_model.dart';
import 'package:district/models/movie/movie_model.dart';

final eventProvider = StateNotifierProvider<EventController, List<EventModel>>((
  ref,
) {
  return EventController(ref.read(eventRepositoryProvider));
});

class EventController extends StateNotifier<List<EventModel>> {
  final EventRepository _repo;
  EventController(this._repo) : super([]);

  Future<void> fetchAllEvents() async {
    final events = await _repo.getAllEvents();
    state = events;
  }
}

final diningProvider =
    StateNotifierProvider<DiningController, List<DiningModel>>((ref) {
      return DiningController(ref.read(diningRepositoryProvider));
    });

class DiningController extends StateNotifier<List<DiningModel>> {
  final DiningRepository _repo;
  DiningController(this._repo) : super([]);

  Future<void> fetchAllDining() async {
    final dining = await _repo.getAllDining();
    state = dining;
  }
}

final diningTypeProvider =
    StateNotifierProvider<DiningTypeController, List<MoodCategory>>((ref) {
      return DiningTypeController(ref.read(diningRepositoryProvider));
    });

class DiningTypeController extends StateNotifier<List<MoodCategory>> {
  final DiningRepository _repo;
  DiningTypeController(this._repo) : super([]);

  Future<void> diningType() async {
    try {
      final moodCategories = await _repo.diningType();
      state = moodCategories;
    } catch (e) {
      state = [];
    }
  }
}

final movieProvider = StateNotifierProvider<MovieController, List<MovieModel>>((
  ref,
) {
  return MovieController(ref.read(movieRepositoryProvider));
});

class MovieController extends StateNotifier<List<MovieModel>> {
  final MovieRepository _repo;
  MovieController(this._repo) : super([]);

  Future<void> fetchAllMovies() async {
    final movies = await _repo.getAllMovies();
    state = movies;
  }
}
