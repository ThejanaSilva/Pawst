import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import '../models/pet.dart';
import '../models/vaccination.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Stream<List<Post>> streamFeed({int limit = 50}) {
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Post.fromMap(doc.data(), id: doc.id)).toList());
  }

  static Future<void> createPost({
    required String authorId,
    required String mediaUrl,
    required String caption,
  }) async {
    await _db.collection('posts').add({
      'authorId': authorId,
      'mediaUrl': mediaUrl,
      'caption': caption,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --- Pets ---
  static Stream<List<Pet>> streamUserPets(String userId) {
    return _db
        .collection('pets')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Pet.fromMap(doc.data()..['id'] = doc.id)).toList());
  }

  static Future<void> addPet(Pet pet) async {
    await _db.collection('pets').add(pet.toMap()..remove('id'));
  }

  // --- Vaccinations ---
  static Stream<List<Vaccination>> streamPetVaccinations(String petId, {bool onlyPublic = false}) {
    var query = _db.collection('vaccinations').where('petId', isEqualTo: petId);
    if (onlyPublic) {
      query = query.where('isPublic', isEqualTo: true);
    }
    return query.snapshots().map((snap) {
      return snap.docs.map((doc) => Vaccination.fromMap(doc.data(), id: doc.id)).toList();
    });
  }

  static Future<void> addVaccination(Vaccination vac) async {
    await _db.collection('vaccinations').add(vac.toMap()..remove('id'));
  }
}
