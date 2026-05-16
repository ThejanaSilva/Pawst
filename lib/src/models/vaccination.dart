import 'package:cloud_firestore/cloud_firestore.dart';

class Vaccination {
  final String id;
  final String petId;
  final String name;
  final DateTime dateAdministered;
  final DateTime? nextDueDate;
  final bool isPublic;

  Vaccination({
    required this.id,
    required this.petId,
    required this.name,
    required this.dateAdministered,
    this.nextDueDate,
    this.isPublic = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'petId': petId,
        'name': name,
        'dateAdministered': dateAdministered,
        'nextDueDate': nextDueDate,
        'isPublic': isPublic,
      };

  static Vaccination fromMap(Map<String, dynamic> m, {String id = ''}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      return DateTime.tryParse((val ?? '').toString()) ?? DateTime.now();
    }

    return Vaccination(
      id: id.isNotEmpty ? id : (m['id'] ?? ''),
      petId: m['petId'] ?? '',
      name: m['name'] ?? '',
      dateAdministered: parseDate(m['dateAdministered']),
      nextDueDate: m['nextDueDate'] != null ? parseDate(m['nextDueDate']) : null,
      isPublic: m['isPublic'] ?? false,
    );
  }
}
