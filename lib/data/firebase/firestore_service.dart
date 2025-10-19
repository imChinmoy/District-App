import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/event_model.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  static Future<List<EventModel>> getAllEvents() async {
    final snapshot = await _db.collection('events').get();
    return snapshot.docs.map((doc) => EventModel.fromMap(doc.data())).toList();
  }

  static Future<EventModel?> getEventById(String id) async {
    final doc = await _db.collection('events').doc(id).get();
    return doc.exists ? EventModel.fromMap(doc.data()!) : null;
  }

  static Future<void> addEvent(EventModel event) async {
    await _db.collection('events').doc(event.id).set(event.toMap());
  }
}
