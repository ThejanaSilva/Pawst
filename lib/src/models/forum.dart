import 'package:cloud_firestore/cloud_firestore.dart';

class ForumTopic {
  final String id;
  final String authorId;
  final String title;
  final String description;
  final DateTime createdAt;

  ForumTopic({
    required this.id,
    required this.authorId,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'authorId': authorId,
        'title': title,
        'description': description,
        'createdAt': createdAt,
      };

  static ForumTopic fromMap(Map<String, dynamic> m, {String id = ''}) {
    final createdRaw = m['createdAt'];
    DateTime created;
    if (createdRaw is Timestamp) {
      created = createdRaw.toDate();
    } else if (createdRaw is DateTime) {
      created = createdRaw;
    } else {
      created = DateTime.tryParse((createdRaw ?? '').toString()) ?? DateTime.now();
    }
    return ForumTopic(
      id: id.isNotEmpty ? id : (m['id'] ?? ''),
      authorId: m['authorId'] ?? '',
      title: m['title'] ?? '',
      description: m['description'] ?? '',
      createdAt: created,
    );
  }
}

class ForumComment {
  final String id;
  final String topicId;
  final String authorId;
  final String text;
  final bool isVetResponse;
  final DateTime createdAt;

  ForumComment({
    required this.id,
    required this.topicId,
    required this.authorId,
    required this.text,
    this.isVetResponse = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'topicId': topicId,
        'authorId': authorId,
        'text': text,
        'isVetResponse': isVetResponse,
        'createdAt': createdAt,
      };

  static ForumComment fromMap(Map<String, dynamic> m, {String id = ''}) {
    final createdRaw = m['createdAt'];
    DateTime created;
    if (createdRaw is Timestamp) {
      created = createdRaw.toDate();
    } else if (createdRaw is DateTime) {
      created = createdRaw;
    } else {
      created = DateTime.tryParse((createdRaw ?? '').toString()) ?? DateTime.now();
    }
    return ForumComment(
      id: id.isNotEmpty ? id : (m['id'] ?? ''),
      topicId: m['topicId'] ?? '',
      authorId: m['authorId'] ?? '',
      text: m['text'] ?? '',
      isVetResponse: m['isVetResponse'] ?? false,
      createdAt: created,
    );
  }
}
