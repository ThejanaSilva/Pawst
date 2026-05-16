import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String authorId; // pet or user id
  final String mediaUrl;
  final String caption;
  final DateTime createdAt;

  Post({required this.id, required this.authorId, required this.mediaUrl, required this.caption, required this.createdAt});

  Map<String, dynamic> toMap() => {
        'id': id,
        'authorId': authorId,
        'mediaUrl': mediaUrl,
        'caption': caption,
        'createdAt': createdAt,
      };

  static Post fromMap(Map<String, dynamic> m, {String id = ''}) {
    final createdRaw = m['createdAt'];
    DateTime created;
    if (createdRaw is Timestamp) {
      created = createdRaw.toDate();
    } else if (createdRaw is DateTime) {
      created = createdRaw;
    } else {
      created = DateTime.tryParse((createdRaw ?? '').toString()) ?? DateTime.now();
    }
    return Post(
      id: id.isNotEmpty ? id : (m['id'] ?? ''),
      authorId: m['authorId'] ?? '',
      mediaUrl: m['mediaUrl'] ?? '',
      caption: m['caption'] ?? '',
      createdAt: created,
    );
  }
}
