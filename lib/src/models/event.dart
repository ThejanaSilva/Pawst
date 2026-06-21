import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String organizerId;
  final String title;
  final String description;
  final String location;
  final DateTime eventDate;
  final List<String> rsvps; // User IDs of attendees
  final DateTime createdAt;

  Event({
    required this.id,
    required this.organizerId,
    required this.title,
    required this.description,
    required this.location,
    required this.eventDate,
    this.rsvps = const [],
    required this.createdAt,
  });

<<<<<<< HEAD
  Map<String, dynamic> toMap() => {
        'id': id,
        'organizerId': organizerId,
        'title': title,
        'description': description,
        'location': location,
        'eventDate': eventDate,
        'rsvps': rsvps,
        'createdAt': createdAt,
      };

  static Event fromMap(Map<String, dynamic> m, {String id = ''}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      return DateTime.tryParse((val ?? '').toString()) ?? DateTime.now();
    }

    return Event(
      id: id.isNotEmpty ? id : (m['id'] ?? ''),
      organizerId: m['organizerId'] ?? '',
      title: m['title'] ?? '',
      description: m['description'] ?? '',
      location: m['location'] ?? '',
      eventDate: parseDate(m['eventDate']),
      rsvps: List<String>.from(m['rsvps'] ?? []),
      createdAt: parseDate(m['createdAt']),
    );
  }
=======
  /// Convert Firestore document data to an [Event] instance.
  factory Event.fromMap(Map<String, dynamic> data, String documentId) {
    // Defensive parsing to avoid runtime crashes when fields are missing or of unexpected type.
    // Firestore may omit optional fields; provide sensible defaults.
    final GeoPoint location = data['location'] is GeoPoint
        ? data['location'] as GeoPoint
        : const GeoPoint(0, 0);
    final Timestamp? ts = data['dateTime'] as Timestamp?;
    final DateTime dateTime = ts != null ? ts.toDate() : DateTime.now();

    return Event(
      id: documentId,
      organizerId: data['organizerId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: location,
      address: data['address'] ?? '',
      dateTime: dateTime,
      imageUrl: data['imageUrl'] as String?,
      attendeeCount: data['attendeeCount'] ?? 0,
    );
  }

  /// Serialize the [Event] to a map suitable for Firestore.
  Map<String, dynamic> toMap() {
    // Include the document ID for consistency with other models.
    return {
      'id': id,
      'organizerId': organizerId,
      'title': title,
      'description': description,
      'location': location,
      'address': address,
      'dateTime': Timestamp.fromDate(dateTime),
      'imageUrl': imageUrl,
      'attendeeCount': attendeeCount,
    };

  }
>>>>>>> origin/dev_wta_v2
}
