import 'package:district/database/firebase/firestore_service.dart';
import 'package:district/models/dining/dining_model.dart';
import 'package:district/models/mood_model.dart';

class DiningRepository {
  final AppDatabase _db;

  DiningRepository(this._db);

  Future<List<DiningModel>> getAllDining() => _db.getAllDiningPlaces();
  Future<DiningModel?> getDiningById(String id) => _db.findDining(id);
  Future<List<MoodCategory>> diningType() => _db.diningType();
}
