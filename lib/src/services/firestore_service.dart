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
    });
  }

  static Future<void> addLostPetReport(LostPetReport report) async {
    await _db.collection('lost_pets').add(report.toMap()
      ..remove('id')
      ..['createdAt'] = FieldValue.serverTimestamp());
  }

  static Future<void> markLostPetAsFound(String reportId) async {
    await _db.collection('lost_pets').doc(reportId).update({'isFound': true});
  }

  // --- Forum ---
  static Stream<List<ForumTopic>> streamForumTopics() {
    return _db.collection('forum_topics').orderBy('createdAt', descending: true).snapshots().map((snap) {
      return snap.docs.map((doc) => ForumTopic.fromMap(doc.data(), id: doc.id)).toList();
    });
  }

  static Future<void> addForumTopic(ForumTopic topic) async {
    await _db.collection('forum_topics').add(topic.toMap()
      ..remove('id')
      ..['createdAt'] = FieldValue.serverTimestamp());
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
    await _db.collection('forum_comments').add(comment.toMap()
      ..remove('id')
      ..['createdAt'] = FieldValue.serverTimestamp());
  }

  // --- Events ---
  static Stream<List<Event>> streamEvents() {
    // Use the 'dateTime' field for filtering upcoming events.
    return _db
        .collection('events')
        .where('dateTime', isGreaterThanOrEqualTo: DateTime.now())
        .orderBy('dateTime')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Event.fromMap(doc.data(), doc.id)).toList());
  }

  static Future<void> addEvent(Event event) async {
    await _db.collection('events').add(event.toMap()
      ..remove('id')
      ..['createdAt'] = FieldValue.serverTimestamp());
  }

  static Future<void> toggleRsvp(String eventId, String userId, bool isAttending) async {
    if (isAttending) {
      await _db.collection('events').doc(eventId).update({
        'rsvps': FieldValue.arrayUnion([userId]),
        'attendeeCount': FieldValue.increment(1),
      });
    } else {
      await _db.collection('events').doc(eventId).update({
        'rsvps': FieldValue.arrayRemove([userId]),
        'attendeeCount': FieldValue.increment(-1),
      });
    }
  }

  // --- Messaging ---
  static Stream<List<ChatRoom>> streamUserChatRooms(String userId) {
    return _db
        .collection('chat_rooms')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ChatRoom.fromFirestore(doc)).toList());
  }

  static Future<String> getOrCreateChatRoom(String userId1, String userId2) async {
    final query = await _db
        .collection('chat_rooms')
        .where('participants', arrayContains: userId1)
        .get();

    for (var doc in query.docs) {
      List<dynamic> participants = doc['participants'] ?? [];
      if (participants.contains(userId2)) {
        return doc.id;
      }
    }

    // Not found, create new
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
        .orderBy('createdAt', descending: true) // To show newest at the bottom usually List is reversed
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList());
  }

  static Future<void> sendMessage(String roomId, String senderId, String content) async {
    final msg = {
      'senderId': senderId,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    };
    await _db.collection('chat_rooms').doc(roomId).collection('messages').add(msg);
    await _db.collection('chat_rooms').doc(roomId).update({
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }
}
