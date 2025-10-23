
import 'package:district/database/firebase/firestore_service.dart';
import 'package:district/models/movie/movie_model.dart';

class MovieRepository {
  final AppDatabase _db;

  MovieRepository(this._db);

  Future<List<MovieModel>> getAllMovies() => _db.getAllMovies();
  Future<MovieModel?> getMovieById(String id) => _db.findMovie(id);
}
