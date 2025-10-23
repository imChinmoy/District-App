import 'package:district/database/firebase/firestore_service.dart';
import 'package:district/models/event/event_model.dart';

class EventRepository {
  final AppDatabase _db;

  EventRepository(this._db);

  Future<List<EventModel>> getAllEvents() => _db.getAllEvents();
  Future<EventModel?> getEventById(String id) => _db.findEvent(id);
}
