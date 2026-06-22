import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventsService {
  final CollectionReference _eventsCol = FirebaseFirestore.instance.collection('events');

  /// Stream of all events ordered by dateTime.
  Stream<List<Event>> getEventsStream() {
    return _eventsCol
        .orderBy('dateTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
            .toList());
  }

  /// Create a new event document.
  Future<void> createEvent(Event event) async {
    await _eventsCol.add(event.toMap());
  }

  /// Update an existing event (identified by its document ID).
  Future<void> updateEvent(Event event) async {
    await _eventsCol.doc(event.id).update(event.toMap());
  }

  /// Delete an event.
  Future<void> deleteEvent(String eventId) async {
    await _eventsCol.doc(eventId).delete();
  }

  /// Toggle RSVP for a user on an event.
  /// Updated to use the `attendeeIds` field (list of user IDs) instead of the deprecated `attendees` field.
  Future<void> toggleRsvp(String eventId, String userId, bool isAttending) async {
    final ref = _eventsCol.doc(eventId);
    if (isAttending) {
      await ref.update({
        'attendeeIds': FieldValue.arrayUnion([userId]),
      });
    } else {
      await ref.update({
        'attendeeIds': FieldValue.arrayRemove([userId]),
      });
    }
  }
}
