import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/event/event_model.dart';
import '../../models/dining/dining_model.dart';
import '../../models/movie/movie_model.dart';

class AppDatabase {
  static final _db = FirebaseFirestore.instance;

  static Future<List<EventModel>> getAllEvents() async {
    final data = await _db.collection('Events').get();
    return data.docs.map((e) => EventModel.fromMap(e.data())).toList();
  }

  Future<EventModel?> findEvent(String id) async {
    final doc = await _db.collection('Events').doc(id).get();
    return doc.exists ? EventModel.fromMap(doc.data()!) : null;
  }



  Future<List<DiningModel>> getAllDiningPlaces() async {
    final data = await _db.collection('DiningPlaces').get();
    return data.docs.map((e) => DiningModel.fromMap(e.data())).toList();
  }

  Future<DiningModel?> findDining(String id) async {
    final doc = await _db.collection('DiningPlaces').doc(id).get();
    return doc.exists ? DiningModel.fromMap(doc.data()!) : null;
  }



  Future<List<MovieModel>> getAllMovies() async {
    final data = await _db.collection('Movies').get();
    return data.docs.map((e) => MovieModel.fromMap(e.data())).toList();
  }

  Future<MovieModel?> findMovie(String id) async {
    final doc = await _db.collection('Movies').doc(id).get();
    return doc.exists ? MovieModel.fromMap(doc.data()!) : null;
  }

}
