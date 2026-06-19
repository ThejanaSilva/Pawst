import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String currentUserId = "user_001"; // replace with auth later

  final Map<String, bool> showPawAnimation = {};

  // =========================
  // STREAM POSTS
  // =========================
  Stream<QuerySnapshot> streamPosts() {
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // =========================
  // TOGGLE PAW (LIKE)
  // =========================
  Future<void> togglePaw(String postId, List pawUsers) async {
    final ref = _db.collection('posts').doc(postId);

    if (pawUsers.contains(currentUserId)) {
      pawUsers.remove(currentUserId);
    } else {
      pawUsers.add(currentUserId);
    }

    await ref.update({
      'pawUsers': pawUsers,
      'pawsCount': pawUsers.length,
    });
  }

  // =========================
  // ADD COMMENT
  // =========================
  Future<void> addComment({
    required String postId,
    required String text,
  }) async {
    await _db.collection('posts').doc(postId).collection('comments').add({
      'userId': currentUserId,
      'username': "you",
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // =========================
  // COMMENTS SHEET
  // =========================
  void _showComments(String postId) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text(
                "Comments",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),

              // COMMENTS STREAM
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _db
                      .collection('posts')
                      .doc(postId)
                      .collection('comments')
                      .orderBy('createdAt', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final comments = snapshot.data!.docs;

                    if (comments.isEmpty) {
                      return const Center(child: Text("No comments yet"));
                    }

                    return ListView(
                      children: comments.map((doc) {
                        final c = doc.data() as Map<String, dynamic>;

                        return ListTile(
                          leading:
                              const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(
                            c['username'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(c['text'] ?? ''),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),

              const Divider(height: 1),

              // INPUT
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const CircleAvatar(child: Icon(Icons.person)),
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
                      onPressed: () async {
                        final text = controller.text.trim();
                        if (text.isEmpty) return;

                        await addComment(
                          postId: postId,
                          text: text,
                        );

                        controller.clear();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================
  // PAW ANIMATION
  // =========================
  void _showPawAnim(String postId) {
    setState(() {
      showPawAnimation[postId] = true;
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          showPawAnimation[postId] = false;
        });
      }
    });
  }

  // =========================
  // UI
  // =========================
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
      body: StreamBuilder<QuerySnapshot>(
        stream: streamPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data?.docs ?? [];

          if (posts.isEmpty) {
            return const Center(
              child: Text(
                "No feed to show 🐾",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final doc = posts[index];
              final post = doc.data() as Map<String, dynamic>;

              final postId = doc.id;
              final pawUsers = List.from(post['pawUsers'] ?? []);
              final pawsCount = post['pawsCount'] ?? 0;

              final isPawed = pawUsers.contains(currentUserId);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(
                      post['username'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.more_vert),
                  ),

                  // IMAGE
                  GestureDetector(
                    onDoubleTap: () async {
                      _showPawAnim(postId);
                      await togglePaw(postId, pawUsers);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: Image.network(
                            post['imageUrl'] ?? '',
                            fit: BoxFit.cover,
                          ),
                        ),
                        AnimatedOpacity(
                          opacity: showPawAnimation[postId] == true ? 1 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(
                            Icons.pets,
                            size: 120,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ACTIONS
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.pets,
                          color: isPawed ? Colors.orange : Colors.grey.shade700,
                        ),
                        onPressed: () async {
                          await togglePaw(postId, pawUsers);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.mode_comment_outlined),
                        onPressed: () => _showComments(postId),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          post['isBookmarked'] == true
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                        ),
                        onPressed: () {
                          _db.collection('posts').doc(postId).update({
                            'isBookmarked': !(post['isBookmarked'] ?? false),
                          });
                        },
                      ),
                    ],
                  ),

                  // PAW COUNT
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "🐾 $pawsCount paws",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // CAPTION
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: "${post['username']} ",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: post['caption'] ?? ''),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Divider(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
