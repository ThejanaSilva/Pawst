import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/pet.dart';
import '../models/appointment.dart';
import '../models/health_record.dart';
import '../models/vaccination.dart';

class PetService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get petsRef =>
      _db.collection('users').doc(uid).collection('pets');

  /// ---------------- PET ----------------

  Stream<List<Pet>> getPets() {
    return petsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Pet.fromMap(data);
      }).toList();
    });
  }

  Future<void> updatePet(Pet pet) async {
    await petsRef.doc(pet.id).set(
          pet.toMap(),
          SetOptions(merge: true),
        );
  }

  /// ---------------- APPOINTMENTS ----------------

  Stream<List<Appointment>> getAppointments(String petId) {
    return petsRef.doc(petId).collection('appointments').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => Appointment.fromMap(doc.data()))
            .toList());
  }

  Future<void> addAppointment(
    String petId,
    Appointment appointment,
  ) async {
    await petsRef
        .doc(petId)
        .collection('appointments')
        .add(appointment.toMap());
  }

  Future<void> deleteAppointment(
    String petId,
    String appointmentId,
  ) async {
    await petsRef
        .doc(petId)
        .collection('appointments')
        .doc(appointmentId)
        .delete();
  }

  /// ---------------- HEALTH RECORDS ----------------

  Stream<List<HealthRecord>> getHealthRecords(String petId) {
    return petsRef.doc(petId).collection('healthRecords').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => HealthRecord.fromMap(doc.data()))
            .toList());
  }

  Future<void> addHealthRecord(
    String petId,
    HealthRecord record,
  ) async {
    await petsRef.doc(petId).collection('healthRecords').add(record.toMap());
  }

  Future<void> deleteHealthRecord(
    String petId,
    String recordId,
  ) async {
    await petsRef.doc(petId).collection('healthRecords').doc(recordId).delete();
  }

  /// ---------------- VACCINATIONS ----------------

  Stream<List<Vaccination>> getVaccinations(String petId) {
    return petsRef
        .doc(petId)
        .collection('vaccinations')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Vaccination.fromMap(
                  doc.data(),
                  id: doc.id,
                ))
            .toList());
  }

  Future<void> addVaccination(
    String petId,
    Vaccination vaccination,
  ) async {
    await petsRef
        .doc(petId)
        .collection('vaccinations')
        .add(vaccination.toMap());
  }

  Future<void> deleteVaccination(
    String petId,
    String vaccinationId,
  ) async {
    await petsRef
        .doc(petId)
        .collection('vaccinations')
        .doc(vaccinationId)
        .delete();
  }
}
