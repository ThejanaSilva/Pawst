class Comment {
  final String username;
  final String text;
  final String? avatarUrl;
  final DateTime createdAt;

  List<Comment> replies;

  Comment({
    required this.username,
    required this.text,
    this.avatarUrl,
    DateTime? createdAt,
    List<Comment>? replies,
  })  : createdAt = createdAt ?? DateTime.now(),
        replies = replies ?? [];
}
