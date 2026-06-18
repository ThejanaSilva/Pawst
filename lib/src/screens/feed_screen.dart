import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/comment.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final List<Post> posts = [
    Post(
      id: "post_1",
      username: "alice",
      imageUrl: "https://picsum.photos/id/237/800/800",
      caption: "Charlie enjoyed the park today 🐶",
      timeAgo: "2h",
      paws: 124,
      comments: [
        Comment(
          username: "petlover",
          text: "Such a happy dog! 🐾",
          replies: [
            Comment(
              username: "alice",
              text: "He loved playing today 😊",
            ),
          ],
        ),
        Comment(
          username: "john",
          text: "Adorable!",
        ),
      ],
    ),
    Post(
      id: "post_2",
      username: "emma",
      imageUrl: "https://picsum.photos/id/1025/800/800",
      caption: "Meet my sleepy puppy ❤️",
      timeAgo: "5h",
      paws: 88,
      comments: [
        Comment(
          username: "lucy",
          text: "So cute 😍",
        ),
      ],
    ),
  ];

  void _showComments(Post post) {
    final controller = TextEditingController();
    Comment? replyingTo;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, sheetSetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.85,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      "Comments",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView(
                        children: post.comments.map((comment) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                                title: Text(
                                  comment.username,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(comment.text),
                                trailing: TextButton(
                                  onPressed: () {
                                    replyingTo = comment;
                                    controller.text = "@${comment.username} ";
                                    sheetSetState(() {});
                                  },
                                  child: const Text("Reply"),
                                ),
                              ),
                              if (comment.replies.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 60),
                                  child: Column(
                                    children: comment.replies
                                        .map(
                                          (reply) => ListTile(
                                            dense: true,
                                            leading: const Icon(
                                              Icons.reply,
                                              size: 18,
                                            ),
                                            title: Text(
                                              reply.username,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Text(reply.text),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    if (replyingTo != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Replying to @${replyingTo!.username}",
                            style: const TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                hintText: "Add a comment...",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              final text = controller.text.trim();

                              if (text.isEmpty) return;

                              setState(() {
                                if (replyingTo == null) {
                                  post.comments.add(
                                    Comment(
                                      username: "you",
                                      text: text,
                                    ),
                                  );
                                } else {
                                  replyingTo!.replies.add(
                                    Comment(
                                      username: "you",
                                      text: text,
                                    ),
                                  );
                                }
                              });

                              controller.clear();
                              replyingTo = null;
                              sheetSetState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  final Map<String, bool> showPawAnimation = {};

  void _pawPost(Post post) {
    if (!post.isPawed) {
      setState(() {
        post.isPawed = true;
        post.paws++;
        showPawAnimation[post.id] = true;
      });

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            showPawAnimation[post.id] = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("PAWST"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(
                  post.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(Icons.more_vert),
              ),
              GestureDetector(
                onDoubleTap: () {
                  _pawPost(post);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Image.network(
                        post.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    AnimatedScale(
                      scale: showPawAnimation[post.id] == true ? 1.0 : 0.5,
                      duration: const Duration(milliseconds: 250),
                      child: AnimatedOpacity(
                        opacity: showPawAnimation[post.id] == true ? 1 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: const Icon(
                          Icons.pets,
                          size: 120,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (post.isPawed) {
                          post.isPawed = false;
                          post.paws--;
                        } else {
                          _pawPost(post);
                        }
                      });
                    },
                    icon: AnimatedScale(
                      scale: post.isPawed ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.pets,
                        color:
                            post.isPawed ? Colors.orange : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showComments(post),
                    icon: const Icon(
                      Icons.mode_comment_outlined,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Share tapped",
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.ios_share_outlined,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        post.isBookmarked = !post.isBookmarked;
                      });
                    },
                    icon: Icon(
                      post.isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Text(
                  "🐾 ${post.paws} paws",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: "${post.username} ",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: post.caption,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => _showComments(post),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Text(
                    "View all ${post.comments.length} comments",
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              if (post.comments.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: "${post.comments.first.username} ",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: post.comments.first.text,
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Text(
                  post.timeAgo,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
            ],
          );
        },
      ),
    );
  }
}
