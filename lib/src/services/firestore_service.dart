import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';

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
}
