import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/post.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'post_editor_screen.dart';
import 'pet_profile_screen.dart';
import 'chat_screen.dart';

class FeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pawst! Feed'),
        actions: [
          IconButton(
            onPressed: () => _showMyPets(context),
            icon: Icon(Icons.pets),
          ),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                p.createdAt.toLocal().toString().split(' ')[0], // Simplify date
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              if (p.authorId != AuthService.currentUser?.uid)
                                TextButton.icon(
                                  icon: Icon(Icons.chat_bubble_outline, size: 16),
                                  label: Text('Message'),
                                  onPressed: () async {
                                    final curUser = AuthService.currentUser;
                                    if (curUser == null) return;
                                    final roomId = await FirestoreService.getOrCreateChatRoom(curUser.uid, p.authorId);
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (_) => ChatScreen(roomId: roomId, otherUserId: p.authorId)
                                    ));
                                  },
                                )
                            ],
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

  void _showMyPets(BuildContext context) {
    final user = AuthService.currentUser;
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        children: [
          ListTile(
            title: Text('My Pets', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                // stub for adding pet
                FirestoreService.addPet(Pet(
                  id: '',
                  ownerId: user.uid,
                  name: 'New Pet ${DateTime.now().second}',
                  species: 'Dog',
                  about: 'A good boy',
                ));
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Pet>>(
              stream: FirestoreService.streamUserPets(user.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final pets = snapshot.data!;
                if (pets.isEmpty) return Center(child: Text('No pets yet. Tap + to add.'));
                return ListView.builder(
                  itemCount: pets.length,
                  itemBuilder: (context, i) {
                    final pet = pets[i];
                    return ListTile(
                      leading: Icon(Icons.pets),
                      title: Text(pet.name),
                      subtitle: Text(pet.species),
                      onTap: () {
                        Navigator.pop(ctx); // close bottom sheet
                        Navigator.push(context, MaterialPageRoute(builder: (_) => PetProfileScreen(pet: pet)));
                      },
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
