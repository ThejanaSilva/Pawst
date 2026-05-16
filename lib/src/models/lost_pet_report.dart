import 'package:cloud_firestore/cloud_firestore.dart';

class LostPetReport {
  final String id;
  final String reporterId;
  final String petName;
  final String species;
  final String breed;
  final String lastKnownLocation;
  final String contactInfo;
  final String photoUrl;
  final bool isFound;
  final DateTime createdAt;

  LostPetReport({
    required this.id,
    required this.reporterId,
    required this.petName,
    required this.species,
    required this.breed,
    required this.lastKnownLocation,
    required this.contactInfo,
    required this.photoUrl,
    this.isFound = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'reporterId': reporterId,
        'petName': petName,
        'species': species,
        'breed': breed,
        'lastKnownLocation': lastKnownLocation,
        'contactInfo': contactInfo,
        'photoUrl': photoUrl,
        'isFound': isFound,
        'createdAt': createdAt,
      };

  static LostPetReport fromMap(Map<String, dynamic> m, {String id = ''}) {
    final createdRaw = m['createdAt'];
    DateTime created;
    if (createdRaw is Timestamp) {
      created = createdRaw.toDate();
    } else if (createdRaw is DateTime) {
      created = createdRaw;
    } else {
      created = DateTime.tryParse((createdRaw ?? '').toString()) ?? DateTime.now();
    }
    return LostPetReport(
      id: id.isNotEmpty ? id : (m['id'] ?? ''),
      reporterId: m['reporterId'] ?? '',
      petName: m['petName'] ?? '',
      species: m['species'] ?? '',
      breed: m['breed'] ?? '',
      lastKnownLocation: m['lastKnownLocation'] ?? '',
      contactInfo: m['contactInfo'] ?? '',
      photoUrl: m['photoUrl'] ?? '',
      isFound: m['isFound'] ?? false,
      createdAt: created,
    );
  }
}
