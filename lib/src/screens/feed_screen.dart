import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'post_editor_screen.dart';

class FeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pawst! Feed'),
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService.signOut();
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => PostEditorScreen()));
        },
        child: Icon(Icons.add_a_photo),
      ),
      body: StreamBuilder<List<Post>>(
        stream: FirestoreService.streamFeed(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load feed'));
          }
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return Center(child: Text('No posts yet. Create the first Pawst!'));
          }
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, i) {
              final p = posts[i];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (p.mediaUrl.isNotEmpty)
                      AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(p.mediaUrl, fit: BoxFit.cover),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.caption, style: TextStyle(fontSize: 16)),
                          SizedBox(height: 6),
                          Text(
                            p.createdAt.toLocal().toString(),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
