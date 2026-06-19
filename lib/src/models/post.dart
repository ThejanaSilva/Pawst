import 'comment.dart';

class Post {
  final String id;
  final String username;
  final String imageUrl;
  final String caption;
  final String timeAgo;

  int paws;
  bool isPawed;
  bool isBookmarked;
  List<Comment> comments;

  Post({
    required this.id,
    required this.username,
    required this.imageUrl,
    required this.caption,
    required this.timeAgo,
    required this.paws,
    required this.comments,
    this.isPawed = false,
    this.isBookmarked = false,
  });

  factory Post.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    return Post(
      id: id,
      username: map['username'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      caption: map['caption'] ?? '',
      timeAgo: map['timeAgo'] ?? '',
      paws: map['paws'] ?? 0,
      isPawed: map['isPawed'] ?? false,
      isBookmarked: map['isBookmarked'] ?? false,
      comments: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'imageUrl': imageUrl,
      'caption': caption,
      'timeAgo': timeAgo,
      'paws': paws,
      'isPawed': isPawed,
      'isBookmarked': isBookmarked,
    };
  }
}
