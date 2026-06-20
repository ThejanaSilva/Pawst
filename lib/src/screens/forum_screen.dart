import 'package:flutter/material.dart';
import '../models/forum.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../screens/topic_detail_screen.dart';

class ForumScreen extends StatelessWidget {
  const ForumScreen({super.key});

  void _showNewTopicDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Ask the Community"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: "Topic Title",
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Describe your issue",
                  prefixIcon: Icon(Icons.description),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text("Post"),
              onPressed: () async {
                final title = titleCtrl.text.trim();
                final desc = descCtrl.text.trim();

                if (title.isEmpty) return;

                final user = AuthService.currentUser;
                if (user == null) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please sign in first")),
                  );
                  return;
                }

                // CLOSE DIALOG FIRST (IMPORTANT FIX)
                Navigator.pop(ctx);

                try {
                  await FirestoreService.addForumTopic(
                    ForumTopic(
                      id: '',
                      authorId: user.uid,
                      title: title,
                      description: desc,
                      createdAt: DateTime.now(),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to post: $e")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Community Forum"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<List<ForumTopic>>(
        stream: FirestoreService.streamForumTopics(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final topics = snapshot.data!;

          if (topics.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.forum_outlined, size: 70, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No discussions yet",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    "Be the first to ask a question!",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: topics.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final topic = topics[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TopicDetailScreen(topic: topic),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.teal.shade100,
                            child: const Icon(Icons.person, color: Colors.teal),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              topic.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        topic.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.chat_bubble_outline,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(
                            "Tap to join discussion",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewTopicDialog(context),
        icon: const Icon(Icons.add_comment),
        label: const Text("Ask"),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
