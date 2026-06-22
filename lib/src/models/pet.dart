import 'appointment.dart';
import 'health_record.dart';
import 'vaccination.dart';

/// Model representing a pet owned by a user.
class Pet {
  // Identification
  final String id;
  final String ownerId;
  final String name;

  // Descriptive attributes
  final String species; // e.g., Dog, Cat
  final String breed;
  final String gender;
  final String bio; // General description
  final String about; // Alias for bio (kept for backward compatibility)
  final String imageUrl;

  // Physical attributes
  final double weightKg;
  final int ageYears;
  final int friendlinessLevel;

  // Compatibility flags
  final bool goodWithDogs;
  final bool goodWithCats;
  final bool goodWithChildren;

  // Vaccination documentation
  final String vaccinationPdfName;

  // Nested collections
  final List<Vaccination> vaccinations;
  final List<Appointment> appointments;
  final List<HealthRecord> healthRecords;

  const Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    required this.breed,
    required this.gender,
    required this.bio,
    required this.about,
    required this.imageUrl,
    required this.weightKg,
    required this.ageYears,
    required this.friendlinessLevel,
    required this.goodWithDogs,
    required this.goodWithCats,
    required this.goodWithChildren,
    required this.vaccinationPdfName,
    required this.vaccinations,
    required this.appointments,
    required this.healthRecords,
  });

  /// Creates a [Pet] instance from a Firestore map.
  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      species: map['species'] ?? '',
      breed: map['breed'] ?? '',
      gender: map['gender'] ?? '',
      bio: map['bio'] ?? '',
      about: map['about'] ?? map['bio'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      weightKg: (map['weightKg'] ?? 0).toDouble(),
      ageYears: map['ageYears'] ?? 0,
      friendlinessLevel: map['friendlinessLevel'] ?? 3,
      goodWithDogs: map['goodWithDogs'] ?? false,
      goodWithCats: map['goodWithCats'] ?? false,
      goodWithChildren: map['goodWithChildren'] ?? false,
      vaccinationPdfName: map['vaccinationPdfName'] ?? '',
      vaccinations: [], // Populate as needed elsewhere
      appointments: [],
      healthRecords: [],
    );
  }

  /// Serialises the [Pet] to a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'species': species,
      'breed': breed,
      'gender': gender,
      'bio': bio,
      'about': about,
      'imageUrl': imageUrl,
      'weightKg': weightKg,
      'ageYears': ageYears,
      'friendlinessLevel': friendlinessLevel,
      'goodWithDogs': goodWithDogs,
      'goodWithCats': goodWithCats,
      'goodWithChildren': goodWithChildren,
      'vaccinationPdfName': vaccinationPdfName,
    };
  }

  /// Returns a copy of this pet with the given fields replaced.
  Pet copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? species,
    String? breed,
    String? gender,
    String? bio,
    String? about,
    String? imageUrl,
    double? weightKg,
    int? ageYears,
    int? friendlinessLevel,
    bool? goodWithDogs,
    bool? goodWithCats,
    bool? goodWithChildren,
    String? vaccinationPdfName,
    List<Vaccination>? vaccinations,
    List<Appointment>? appointments,
    List<HealthRecord>? healthRecords,
  }) {
    return Pet(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      about: about ?? this.about,
      imageUrl: imageUrl ?? this.imageUrl,
      weightKg: weightKg ?? this.weightKg,
      ageYears: ageYears ?? this.ageYears,
      friendlinessLevel: friendlinessLevel ?? this.friendlinessLevel,
      goodWithDogs: goodWithDogs ?? this.goodWithDogs,
      goodWithCats: goodWithCats ?? this.goodWithCats,
      goodWithChildren: goodWithChildren ?? this.goodWithChildren,
      vaccinationPdfName: vaccinationPdfName ?? this.vaccinationPdfName,
      vaccinations: vaccinations ?? this.vaccinations,
      appointments: appointments ?? this.appointments,
      healthRecords: healthRecords ?? this.healthRecords,
    );
  }
}
