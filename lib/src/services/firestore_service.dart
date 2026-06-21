import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/forum.dart';
import '../models/event.dart';
import '../models/lost_pet_report.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =====================================================
  // 📌 LOST PETS
  // =====================================================

  static Stream<List<LostPetReport>> streamLostPets() {
    return _db
        .collection('lost_pets')
        .where('isFound', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
<<<<<<< HEAD
        .map((snap) {
      return snap.docs.map((doc) {
        return LostPetReport.fromMap(doc.data(), id: doc.id);
      }).toList();
=======
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

  // --- Lost Pets ---
  static Stream<List<LostPetReport>> streamLostPets({bool excludeFound = true}) {
    // Query the collection, optionally filtering out found reports.
    // Use a Query type to allow chaining where() without type conflicts.
    Query<Map<String, dynamic>> query = _db.collection('lost_pets');
    if (excludeFound) {
      query = query.where('isFound', isEqualTo: false);
    }
    // Retrieve snapshots and sort client‑side by createdAt descending to avoid
    // requiring a composite index on Firestore (where + orderBy).
    return query.snapshots().map((snap) {
      final list = snap.docs
          .map((doc) => LostPetReport.fromMap(doc.data(), id: doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }).handleError((error, stack) {
      // Log the error for debugging and return an empty list to avoid UI crash.
      // In a real app you might use a logging service.
      print('Error streaming lost pets: $error');
      return <LostPetReport>[];
>>>>>>> origin/dev_wta_v2
    });
  }

  static Future<void> addLostPetReport(LostPetReport report) async {
    await _db.collection('lost_pets').add({
      'reporterId': report.reporterId,
      'petName': report.petName,
      'species': report.species,
      'breed': report.breed,
      'lastKnownLocation': report.lastKnownLocation,
      'contactInfo': report.contactInfo,
      'photoUrl': report.photoUrl,
      'isFound': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> markPetFound(String reportId) async {
    await _db.collection('lost_pets').doc(reportId).update({
      'isFound': true,
    });
  }

  // =====================================================
  // 🎉 EVENTS
  // =====================================================

  static Stream<List<Event>> streamEvents() {
    return _db
        .collection('events')
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        return Event.fromMap(doc.data(), id: doc.id);
      }).toList();
    });
  }

  static Future<void> addEvent(Event event) async {
    await _db.collection('events').add({
      'title': event.title,
      'description': event.description,
      'location': event.location,
      'eventDate': event.eventDate,
      'rsvps': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> toggleRsvp(
    String eventId,
    String userId,
    bool isAttending,
  ) async {
    final ref = _db.collection('events').doc(eventId);

    if (isAttending) {
      await ref.update({
        'rsvps': FieldValue.arrayUnion([userId]),
      });
    } else {
      await ref.update({
        'rsvps': FieldValue.arrayRemove([userId]),
      });
    }
  }

  // =====================================================
  // 💬 FORUM
  // =====================================================

  static Stream<List<ForumTopic>> streamForumTopics() {
    return _db
        .collection('forum_topics')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        return ForumTopic.fromMap(doc.data(), id: doc.id);
      }).toList();
    });
  }

  static Future<void> addForumTopic(ForumTopic topic) async {
    await _db.collection('forum_topics').add({
      'authorId': topic.authorId,
      'title': topic.title,
      'description': topic.description,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<List<ForumComment>> streamTopicComments(String topicId) {
    return _db
        .collection('forum_comments')
        .where('topicId', isEqualTo: topicId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        return ForumComment.fromMap(doc.data(), id: doc.id);
      }).toList();
    });
  }

  static Future<void> addForumComment(ForumComment comment) async {
    await _db.collection('forum_comments').add({
      'topicId': comment.topicId,
      'authorId': comment.authorId,
      'text': comment.text,
      'isVetResponse': comment.isVetResponse,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
