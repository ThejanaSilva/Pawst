import 'package:flutter/material.dart';
import '../models/forum.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class TopicDetailScreen extends StatefulWidget {
  final ForumTopic topic;

  const TopicDetailScreen({Key? key, required this.topic}) : super(key: key);

  @override
  _TopicDetailScreenState createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  final _commentCtrl = TextEditingController();
  bool _isSending = false;

  Future<void> _postComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;

    final user = AuthService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in to reply.')));
      return;
    }

    setState(() => _isSending = true);
    try {
      // Mocking vet response to true if you are testing the vet badge 
      // Replace with actual role check in production
      bool isVet = false; // user.role == 'veterinarian'
      
      await FirestoreService.addForumComment(
        ForumComment(
          id: '',
          topicId: widget.topic.id,
          authorId: user.uid,
          text: text,
          isVetResponse: isVet,
          createdAt: DateTime.now(),
        )
      );
      _commentCtrl.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to post reply: $e')));
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discussion')),
      body: Column(
        children: [
          // Topic Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.teal.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.topic.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(widget.topic.description, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Posted on ${widget.topic.createdAt.toString().split('.')[0]}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600))
              ],
            ),
          ),
          const Divider(height: 1),
          // Comments Stream
          Expanded(
            child: StreamBuilder<List<ForumComment>>(
              stream: FirestoreService.streamTopicComments(widget.topic.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final comments = snapshot.data!;
                if (comments.isEmpty) return const Center(child: Text('No replies yet. Be the first to help!'));
                
                return ListView.builder(
                  reverse: true, // Display latest at the bottom next to the input
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: comment.isVetResponse ? Colors.green.shade100 : Colors.blue.shade100,
                        child: Icon(
                          comment.isVetResponse ? Icons.medical_services : Icons.person,
                          color: comment.isVetResponse ? Colors.green.shade800 : Colors.blue.shade800
                        ),
                      ),
                      title: Text(comment.text),
                      subtitle: Text(
                        (comment.isVetResponse ? 'Verified Veterinarian • ' : 'Community Member • ') + 
                        comment.createdAt.toString().split('.')[0],
                        style: TextStyle(color: comment.isVetResponse ? Colors.green.shade700 : Colors.grey)
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Comment Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentCtrl,
                    decoration: InputDecoration(
                      hintText: 'Add a helpful reply...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                _isSending
                  ? const Padding(padding: EdgeInsets.all(12.0), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))
                  : IconButton(
                      icon: const Icon(Icons.send, color: Colors.teal),
                      onPressed: _postComment,
                    )
              ],
            )
          )
        ],
      ),
    );
  }
}
