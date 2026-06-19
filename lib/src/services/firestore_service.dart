import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/post.dart';
import '../models/pet.dart';
import '../models/vaccination.dart';
import '../models/lost_pet_report.dart';
import '../models/forum.dart';
import '../models/event.dart';
import '../models/chat.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ----------------------------
  // 📸 FEED / POSTS
  // ----------------------------

  static Stream<List<Post>> streamFeed({int limit = 50}) {
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        return Post.fromMap(data, id: doc.id);
      }).toList();
    });
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

  // ----------------------------
  // 🐶 PETS
  // ----------------------------

  static Stream<List<Pet>> streamUserPets(String userId) {
    return _db
        .collection('pets')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        return Pet.fromMap({...data, 'id': doc.id});
      }).toList();
    });
  }

  static Future<void> addPet(Pet pet) async {
    final data = pet.toMap();
    data.remove('id');

    await _db.collection('pets').add(data);
  }

  static Future<void> updatePet(Pet pet) async {
    final data = pet.toMap();
    data.remove('id');

    await _db.collection('pets').doc(pet.id).update(data);
  }

  // ----------------------------
  // 💉 VACCINATIONS
  // ----------------------------

  static Stream<List<Vaccination>> streamPetVaccinations(
    String petId, {
    bool onlyPublic = false,
  }) {
    Query query =
        _db.collection('vaccinations').where('petId', isEqualTo: petId);

    if (onlyPublic) {
      query = query.where('isPublic', isEqualTo: true);
    }

    return query.snapshots().map((snap) {
      return snap.docs.map((doc) {
        return Vaccination.fromMap(doc.data() as Map<String, dynamic>,
            id: doc.id);
      }).toList();
    });
  }

  static Future<void> addVaccination(Vaccination vac) async {
    final data = vac.toMap();
    data.remove('id');

    await _db.collection('vaccinations').add(data);
  }

  // ----------------------------
  // 🐾 LOST PETS
  // ----------------------------

  static Stream<List<LostPetReport>> streamLostPets({
    bool excludeFound = true,
  }) {
    Query query =
        _db.collection('lost_pets').orderBy('createdAt', descending: true);

    if (excludeFound) {
      query = query.where('isFound', isEqualTo: false);
    }

    return query.snapshots().map((snap) {
      return snap.docs.map((doc) {
        return LostPetReport.fromMap(doc.data() as Map<String, dynamic>,
            id: doc.id);
      }).toList();
    });
  }

  static Future<void> addLostPetReport(LostPetReport report) async {
    final data = report.toMap();
    data.remove('id');
    data['createdAt'] = FieldValue.serverTimestamp();

    await _db.collection('lost_pets').add(data);
  }

  static Future<void> markLostPetAsFound(String reportId) async {
    await _db.collection('lost_pets').doc(reportId).update({
      'isFound': true,
    });
  }

  // ----------------------------
  // 💬 FORUM
  // ----------------------------

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
    final data = topic.toMap();
    data.remove('id');
    data['createdAt'] = FieldValue.serverTimestamp();

    await _db.collection('forum_topics').add(data);
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
    final data = comment.toMap();
    data.remove('id');
    data['createdAt'] = FieldValue.serverTimestamp();

    await _db.collection('forum_comments').add(data);
  }

  // ----------------------------
  // 🎉 EVENTS
  // ----------------------------

  static Stream<List<Event>> streamEvents() {
    return _db
        .collection('events')
        .where('eventDate', isGreaterThanOrEqualTo: DateTime.now())
        .orderBy('eventDate')
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        return Event.fromMap(doc.data(), id: doc.id);
      }).toList();
    });
  }

  static Future<void> addEvent(Event event) async {
    final data = event.toMap();
    data.remove('id');
    data['createdAt'] = FieldValue.serverTimestamp();

    await _db.collection('events').add(data);
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

  // ----------------------------
  // 💬 CHAT SYSTEM
  // ----------------------------

  static Stream<List<ChatRoom>> streamUserChatRooms(String userId) {
    return _db
        .collection('chat_rooms')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        return ChatRoom.fromFirestore(doc);
      }).toList();
    });
  }

  static Future<String> getOrCreateChatRoom(
    String userId1,
    String userId2,
  ) async {
    final query = await _db
        .collection('chat_rooms')
        .where('participants', arrayContains: userId1)
        .get();

    for (var doc in query.docs) {
      final participants = List<String>.from(doc['participants'] ?? []);
      if (participants.contains(userId2)) {
        return doc.id;
      }
    }

    final newRoom = await _db.collection('chat_rooms').add({
      'participants': [userId1, userId2],
      'lastMessage': null,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    return newRoom.id;
  }

  static Stream<List<ChatMessage>> streamChatMessages(String roomId) {
    return _db
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        return ChatMessage.fromFirestore(doc);
      }).toList();
    });
  }

  static Future<void> sendMessage(
    String roomId,
    String senderId,
    String content,
  ) async {
    final roomRef = _db.collection('chat_rooms').doc(roomId);

    await roomRef.collection('messages').add({
      'senderId': senderId,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    await roomRef.update({
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }
}
