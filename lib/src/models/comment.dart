
class Comment {
  final String username;
  final String text;
  final List<Comment> replies;

  Comment({
    required this.username,
    required this.text,
    this.replies = const [],
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      username: map['username'] ?? '',
      text: map['text'] ?? '',
      replies: (map['replies'] as List<dynamic>? ?? [])
          .map((e) => Comment.fromMap(e))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "username": username,
      "text": text,
      "replies": replies.map((r) => r.toMap()).toList(),
    };
  }
}
