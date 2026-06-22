import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/forum.dart';
import '../models/event.dart';
import '../models/lost_pet_report.dart';
import '../models/pet.dart';
import '../models/vaccination.dart';
import '../models/chat.dart';
import '../models/post.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =====================================================
  // PETS
  // =====================================================
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

  // =====================================================
  // POSTS
  // =====================================================
  /// Adds a new [Post] to the Firestore `posts` collection.
  /// The `id` field is omitted because Firestore generates it.
  static Future<void> createPost(Post post) async {
    await _db.collection('posts').add(post.toMap()..remove('id'));
  }

  // =====================================================
  // VACCINATIONS
  // =====================================================
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

  // =====================================================
  // LOST PETS
  // =====================================================
  static Stream<List<LostPetReport>> streamLostPets({bool excludeFound = true}) {
    Query<Map<String, dynamic>> query = _db.collection('lost_pets');
    if (excludeFound) {
      query = query.where('isFound', isEqualTo: false);
    }
    return query.snapshots().map((snap) {
      final list = snap.docs
          .map((doc) => LostPetReport.fromMap(doc.data(), id: doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }).handleError((error, stack) {
      debugPrint('Error streaming lost pets: $error');
      return <LostPetReport>[];
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
  // EVENTS
  // =====================================================
  static Stream<List<Event>> streamEvents() {
    return _db
        .collection('events')
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) => Event.fromMap(doc.data(), id: doc.id)).toList();
    });
  }

  static Future<void> addEvent(Event event) async {
    await _db.collection('events').add({
      'organizerId': event.organizerId,
      'title': event.title,
      'description': event.description,
      'location': event.location,
      'address': event.address,
      'dateTime': event.dateTime,
      'imageUrl': event.imageUrl,
      'attendeeCount': event.attendeeCount,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> toggleRsvp(String eventId, String userId, bool isAttending) async {
    final ref = _db.collection('events').doc(eventId);
    if (isAttending) {
      await ref.update({
        // Update the list of attendee IDs stored in the event document.
        'attendeeIds': FieldValue.arrayUnion([userId]),
      });
    } else {
      await ref.update({
        'attendeeIds': FieldValue.arrayRemove([userId]),
      });
    }
  }

  // =====================================================
  // FORUM
  // =====================================================
  static Stream<List<ForumTopic>> streamForumTopics() {
    return _db
        .collection('forum_topics')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) => ForumTopic.fromMap(doc.data(), id: doc.id)).toList();
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
      return snap.docs.map((doc) => ForumComment.fromMap(doc.data(), id: doc.id)).toList();
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

  // =====================================================
  // CHAT
  // =====================================================
  static Stream<List<ChatRoom>> streamUserChatRooms(String userId) {
    return _db
        .collection('chat_rooms')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((doc) => ChatRoom.fromMap(doc.data(), id: doc.id))
          .toList();
    });
  }

  static Stream<List<ChatMessage>> streamChatMessages(String roomId) {
    return _db
        .collection('chat_messages')
        .where('roomId', isEqualTo: roomId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((doc) => ChatMessage.fromMap(doc.data(), id: doc.id))
          .toList();
    });
  }

  static Future<void> sendMessage(String roomId, String senderId, String text) async {
    await _db.collection('chat_messages').add({
      'roomId': roomId,
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update last message in chat room
    await _db.collection('chat_rooms').doc(roomId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  static Future<String> createChatRoom(String userId1, String userId2) async {
    // Check if chat room already exists
    final existingRooms = await _db
        .collection('chat_rooms')
        .where('participants', arrayContains: userId1)
        .get();

    for (final doc in existingRooms.docs) {
      final participants = List<String>.from(doc.data()['participants']);
      if (participants.contains(userId2)) {
        return doc.id;
      }
    }

    // Create new chat room
    final newRoom = await _db.collection('chat_rooms').add({
      'participants': [userId1, userId2],
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return newRoom.id;
  }
}
