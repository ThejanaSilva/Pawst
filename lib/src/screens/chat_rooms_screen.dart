import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'chat_screen.dart';

class ChatRoomsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final curUser = AuthService.currentUser;
    if (curUser == null) return Scaffold(body: Center(child: Text('Must be logged in to view chats')));

    return Scaffold(
      appBar: AppBar(title: Text('Direct Messages')),
      body: StreamBuilder<List<ChatRoom>>(
        stream: FirestoreService.streamUserChatRooms(curUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error loading chats'));

          final rooms = snapshot.data ?? [];
          if (rooms.isEmpty) return Center(child: Text('No active chats. Start one from the Feed!'));

          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, i) {
              final room = rooms[i];
              // Get the OTHER participant ID for display placeholder
              final otherId = room.participants.firstWhere((id) => id != curUser.uid, orElse: () => 'Unknown');

              return ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text('User: $otherId'), // Simple way to show the other user
                subtitle: Text(
                  room.lastMessage ?? 'New Chat',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(roomId: room.id, otherUserId: otherId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
