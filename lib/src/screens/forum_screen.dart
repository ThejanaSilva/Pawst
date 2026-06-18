import 'package:flutter/material.dart';
import '../models/forum.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'topic_detail_screen.dart';

class ForumScreen extends StatelessWidget {
  const ForumScreen({super.key});

  
  void _showNewTopicDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ask the Community'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Topic Title')),
            const SizedBox(height: 8),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description (Provide symptoms, breed, etc.)'), maxLines: 4),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              final user = AuthService.currentUser;
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Must be signed in.')));
                return;
              }
              await FirestoreService.addForumTopic(
                ForumTopic(
                  id: '',
                  authorId: user.uid,
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  createdAt: DateTime.now(),
                )
              );
              Navigator.pop(ctx);
            },
            child: const Text('Post'),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vet & Community Forum')),
      body: StreamBuilder<List<ForumTopic>>(
        stream: FirestoreService.streamForumTopics(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final topics = snapshot.data!;
          if (topics.isEmpty) return const Center(child: Text('No questions yet. Be the first to ask!'));

          return ListView.builder(
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const Icon(Icons.forum, color: Colors.teal, size: 36),
                  title: Text(topic.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    topic.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => TopicDetailScreen(topic: topic)));
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewTopicDialog(context),
        tooltip: 'Ask a Question',
        child: const Icon(Icons.edit_document),
      ),
    );
  }
}
