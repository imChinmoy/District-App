import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:district/models/event/artist_model.dart';
import 'package:district/models/mood_model.dart';
import '../../models/event/event_model.dart';
import '../../models/dining/dining_model.dart';
import '../../models/movie/movie_model.dart';
import 'dart:developer';

class AppDatabase {
  static final _db = FirebaseFirestore.instance;

  Future<List<EventModel>> getAllEvents() async {
    try {
      final data = await _db.collection('events').get();
      log('Fetched ${data.docs.length} events from Firestore.');
      return data.docs.map((e) => EventModel.fromMap(e.data())).toList();
    } catch (e) {
      log("Firestore Error fetching events:", error: e);
      return [];
    }
  }

  Future<List<ArtistModel>> getAllArtists() async {
    try {
      final data = await _db.collection('artists').get();
      log('Fetched ${data.docs.length} artists from Firestore.');
      return data.docs.map((e) => ArtistModel.fromMap(e.data())).toList();
    } catch (e) {
      log("Firestore Error fetching artists:", error: e);
      return [];
    }
  }

  Future<EventModel?> findEvent(String id) async {
    final doc = await _db.collection('events').doc(id).get();
    return doc.exists ? EventModel.fromMap(doc.data()!) : null;
  }

  Future<List<DiningModel>> getAllDiningPlaces() async {
    try {
      final data = await _db.collection('restaurants').get();
      return data.docs.map((e) => DiningModel.fromMap(e.data())).toList();
    } catch (e) {
      log("Firestore Error :", error: e);
      return [];
    }
  }

  Future<DiningModel?> findDining(String id) async {
    try {
      final doc = await _db.collection('restaurants').doc(id).get();
      return doc.exists ? DiningModel.fromMap(doc.data()!) : null;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<List<MoodCategory>> diningType() async {
    try {
      final data = await _db.collection('categories').get();
      return data.docs.map((e) => MoodCategory.fromMap(e.data())).toList();
    } catch (e) {
      log("Error : ", error: e);
      return [];
    }
  }

  Future<List<MovieModel>> getAllMovies() async {
    try{
      final data = await _db.collection('movies').get();
    return data.docs.map((e) => MovieModel.fromMap(e.data())).toList();
    }
    catch(e){
      log("Error : ", error: e);
      return [];
    }
  }

  Future<MovieModel?> findMovie(String id) async {
    final doc = await _db.collection('movies').doc(id).get();
    return doc.exists ? MovieModel.fromMap(doc.data()!) : null;
  }
}
