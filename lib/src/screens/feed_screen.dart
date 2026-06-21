import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/post.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'post_editor_screen.dart';
import 'pet_profile_screen.dart';
import 'chat_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  // Shows a dialog to add a new pet. Collects basic details and creates the pet in Firestore.
  void _showAddPetDialog(BuildContext context, String ownerId) {
    final nameCtrl = TextEditingController();
    final speciesCtrl = TextEditingController();
    final aboutCtrl = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Add New Pet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: speciesCtrl, decoration: const InputDecoration(labelText: 'Species')),
              TextField(controller: aboutCtrl, decoration: const InputDecoration(labelText: 'About'), maxLines: 2),
              if (isSubmitting) const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator()),
            ],
          ),
          actions: [
            TextButton(onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (nameCtrl.text.trim().isEmpty) return;
                      setState(() => isSubmitting = true);
                      try {
                        await FirestoreService.addPet(
                          Pet(
                            id: '',
                            ownerId: ownerId,
                            name: nameCtrl.text.trim(),
                            species: speciesCtrl.text.trim(),
                            about: aboutCtrl.text.trim(),
                          ),
                        );
                        Navigator.pop(dialogContext);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add pet: $e')));
                      } finally {
                        setState(() => isSubmitting = false);
                      }
                    },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pawst! Feed'),
        actions: [
          IconButton(
            onPressed: () => _showMyPets(context),
            icon: const Icon(Icons.pets),
          ),
          IconButton(
            onPressed: () async {
              await AuthService.signOut();
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PostEditorScreen()));
        },
        child: const Icon(Icons.add_a_photo),
      ),
      body: StreamBuilder<List<Post>>(
        stream: FirestoreService.streamFeed(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load feed'));
          }
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return const Center(child: Text('No posts yet. Create the first Pawst!'));
          }
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, i) {
              final p = posts[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                          Text(p.caption, style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                p.createdAt.toLocal().toString().split(' ')[0], // Simplify date
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              if (p.authorId != AuthService.currentUser?.uid)
                                TextButton.icon(
                                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                                  label: const Text('Message'),
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
            title: const Text('My Pets', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddPetDialog(context, user.uid),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Pet>>(
              stream: FirestoreService.streamUserPets(user.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final pets = snapshot.data!;
                if (pets.isEmpty) return const Center(child: Text('No pets yet. Tap + to add.'));
                return ListView.builder(
                  itemCount: pets.length,
                  itemBuilder: (context, i) {
                    final pet = pets[i];
                    return ListTile(
                      leading: const Icon(Icons.pets),
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
