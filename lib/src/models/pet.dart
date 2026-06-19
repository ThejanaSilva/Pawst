import 'appointment.dart';
import 'health_record.dart';
import 'vaccination.dart';

class Pet {
  final String id;
  final String name;
  final String breed;
  final String gender;
  final String bio;
  final String imageUrl;

  final double weightKg;
  final int ageYears;
  final int friendlinessLevel;

  final bool goodWithDogs;
  final bool goodWithCats;
  final bool goodWithChildren;

  final String vaccinationPdfName;

  final List<Vaccination> vaccinations;
  final List<Appointment> appointments;
  final List<HealthRecord> healthRecords;

  const Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.gender,
    required this.bio,
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

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      breed: map['breed'] ?? '',
      gender: map['gender'] ?? '',
      bio: map['bio'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      weightKg: (map['weightKg'] ?? 0).toDouble(),
      ageYears: map['ageYears'] ?? 0,
      friendlinessLevel: map['friendlinessLevel'] ?? 3,
      goodWithDogs: map['goodWithDogs'] ?? false,
      goodWithCats: map['goodWithCats'] ?? false,
      goodWithChildren: map['goodWithChildren'] ?? false,
      vaccinationPdfName: map['vaccinationPdfName'] ?? '',
      vaccinations: [],
      appointments: [],
      healthRecords: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'gender': gender,
      'bio': bio,
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

  Pet copyWith({
    String? id,
    String? name,
    String? breed,
    String? gender,
    String? bio,
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
      name: name ?? this.name,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
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
