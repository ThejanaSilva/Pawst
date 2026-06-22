import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String organizerId;
  final String title;
  final String description;
  final GeoPoint location;
  final String address;
  final DateTime dateTime;
  final String? imageUrl;
  final int attendeeCount;
  final List<String> attendeeIds;

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
    this.attendeeIds = const [],
  });

  /// Convert Firestore document data to an [Event] instance.
  factory Event.fromMap(Map<String, dynamic> data, {required String id}) {
    // Defensive parsing to avoid runtime crashes when fields are missing or of unexpected type.
    final GeoPoint location = data['location'] is GeoPoint
        ? data['location'] as GeoPoint
        : const GeoPoint(0, 0);
    final Timestamp? ts = data['dateTime'] as Timestamp?;
    final DateTime dateTime = ts != null ? ts.toDate() : DateTime.now();
    final attendeeIds = (data['attendeeIds'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [];
    return Event(
      id: id,
      organizerId: data['organizerId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      location: location,
      address: data['address'] as String? ?? '',
      dateTime: dateTime,
      imageUrl: data['imageUrl'] as String?,
      attendeeCount: data['attendeeCount'] as int? ?? 0,
      attendeeIds: attendeeIds,
    );
  }

  /// Serialize the [Event] to a map suitable for Firestore.
  Map<String, dynamic> toMap() {
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
      'attendeeIds': attendeeIds,
    };
  }
}
