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
}
