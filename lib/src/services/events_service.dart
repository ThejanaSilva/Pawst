import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventsService {
  final CollectionReference _eventsCol =
      FirebaseFirestore.instance.collection('events');

  /// Stream of all events ordered by dateTime.
  Stream<List<Event>> getEventsStream() {
    return _eventsCol
        .orderBy('dateTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromMap(doc.data() as Map<String, dynamic>, doc.id)
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
    GeoPoint? location,
    String? address,
    DateTime? dateTime,
    String? imageUrl,
    int? attendeeCount,
  }) {
    return Event(
      id: id ?? this.id,
      organizerId: organizerId ?? this.organizerId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      address: address ?? this.address,
      dateTime: dateTime ?? this.dateTime,
      imageUrl: imageUrl ?? this.imageUrl,
      attendeeCount: attendeeCount ?? this.attendeeCount,
    );
  }
}
