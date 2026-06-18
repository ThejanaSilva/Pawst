import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing an Event / Meetup.
///
/// The location is stored as a Firestore [GeoPoint] for precise latitude/longitude
/// and an optional human‑readable [address] string for display.
/// The [attendeeCount] reflects the number of users who have RSVP'd.
class Event {
  final String id;
  final String organizerId;
  final String title;
  final String description;
  final GeoPoint location; // latitude & longitude
  final String address; // readable address
  final DateTime dateTime;
  final String? imageUrl; // optional event image stored in Firebase Storage
  final int attendeeCount;

  Event({
    required this.id,
    required this.organizerId,
    required this.title,
    required this.description,
    required this.location,
    required this.address,
    required this.dateTime,
    this.imageUrl,
    this.attendeeCount = 0,
  });

  /// Convert Firestore document data to an [Event] instance.
  factory Event.fromMap(Map<String, dynamic> data, String documentId) {
    return Event(
      id: documentId,
      organizerId: data['organizerId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] as GeoPoint,
      address: data['address'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] as String?,
      attendeeCount: data['attendeeCount'] ?? 0,
    );
  }

  /// Serialize the [Event] to a map suitable for Firestore.
  Map<String, dynamic> toMap() {
    return {
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
}
