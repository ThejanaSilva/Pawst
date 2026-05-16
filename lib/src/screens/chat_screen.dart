import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String otherUserId;

  const ChatScreen({super.key, required this.roomId, required this.otherUserId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgController = TextEditingController();

  void _send() async {
    final t = _msgController.text.trim();
    if (t.isEmpty) return;

    final curUser = AuthService.currentUser;
    if (curUser == null) return;

    _msgController.clear();
    await FirestoreService.sendMessage(widget.roomId, curUser.uid, t);
  }

  @override
  Widget build(BuildContext context) {
    final curUid = AuthService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: Text('Chat with ${widget.otherUserId}')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: FirestoreService.streamChatMessages(widget.roomId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return const Center(child: Text('Error loading messages'));

                final msgs = snapshot.data ?? [];
                if (msgs.isEmpty) return const Center(child: Text('No messages yet. Say hi!'));

                return ListView.builder(
                  reverse: true,
                  itemCount: msgs.length,
                  itemBuilder: (context, i) {
                    final m = msgs[i];
                    final isMe = m.senderId == curUid;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.teal[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(m.content),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.teal),
                    onPressed: _send,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
