import 'package:district/database/firebase/firestore_service.dart';
import 'package:district/models/dining/dining_model.dart';

class DiningRepository {
  final AppDatabase _db;

  DiningRepository(this._db);

  Future<List<DiningModel>> getAllDining() => _db.getAllDiningPlaces();
  Future<DiningModel?> getDiningById(String id) => _db.findDining(id);
}
