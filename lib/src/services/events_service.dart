import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventsService {
  final CollectionReference _eventsCol =
      FirebaseFirestore.instance.collection('events');

  /// Stream of all events ordered by dateTime.
  Stream<List<Event>> getEventsStream() {
    // Order by the correct field name defined in Event model
    return _eventsCol.orderBy('eventDate').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) =>
                Event.fromMap(doc.data() as Map<String, dynamic>, id: doc.id)
                    .copyWith(id: doc.id))
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
}

extension _EventCopy on Event {
  Event copyWith({
    String? id,
    String? organizerId,
    String? title,
    String? description,
    String? location,
    DateTime? eventDate,
    List<String>? rsvps,
    DateTime? createdAt,
  }) {
    return Event(
      id: id ?? this.id,
      organizerId: organizerId ?? this.organizerId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      eventDate: eventDate ?? this.eventDate,
      rsvps: rsvps ?? this.rsvps,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
