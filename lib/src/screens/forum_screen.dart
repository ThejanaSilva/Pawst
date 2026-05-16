import 'package:flutter/material.dart';
import '../models/forum.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'topic_detail_screen.dart';

class ForumScreen extends StatelessWidget {
  
  void _showNewTopicDialog(BuildContext context) {
    final _titleCtrl = TextEditingController();
    final _descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ask the Community'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleCtrl, decoration: InputDecoration(labelText: 'Topic Title')),
            SizedBox(height: 8),
            TextField(controller: _descCtrl, decoration: InputDecoration(labelText: 'Description (Provide symptoms, breed, etc.)'), maxLines: 4),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (_titleCtrl.text.trim().isEmpty) return;
              final user = AuthService.currentUser;
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Must be signed in.')));
                return;
              }
              await FirestoreService.addForumTopic(
                ForumTopic(
                  id: '',
                  authorId: user.uid,
                  title: _titleCtrl.text.trim(),
                  description: _descCtrl.text.trim(),
                  createdAt: DateTime.now(),
                )
              );
              Navigator.pop(ctx);
            },
            child: Text('Post'),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vet & Community Forum')),
      body: StreamBuilder<List<ForumTopic>>(
        stream: FirestoreService.streamForumTopics(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final topics = snapshot.data!;
          if (topics.isEmpty) return Center(child: Text('No questions yet. Be the first to ask!'));

          return ListView.builder(
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  leading: Icon(Icons.forum, color: Colors.teal, size: 36),
                  title: Text(topic.title, style: TextStyle(fontWeight: FontWeight.bold)),
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
        child: Icon(Icons.edit_document),
        tooltip: 'Ask a Question',
      ),
    );
  }
}
