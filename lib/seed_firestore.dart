// Firestore seeding utility.
// This file populates the Firestore emulator (or real Firestore) with initial
// test data required for the app to function out‑of‑the‑box. Currently it adds a
// sample pet for the anonymously signed‑in user and a few example posts.
// Extend this method with additional collections as needed.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'src/models/pet.dart';
import 'src/models/post.dart';
import 'src/models/event.dart';
import 'src/models/forum.dart';
import 'src/models/lost_pet_report.dart';
import 'src/models/vaccination.dart';

class FirestoreSeed {
  static Future<void> seedAll() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // No authenticated user – nothing to seed.
      return;
    }

    final db = FirebaseFirestore.instance;

    // ---- Seed Pets ----
    // Check if the user already has a pet document.
    final petQuery = await db.collection('pets').where('ownerId', isEqualTo: user.uid).limit(1).get();
    if (petQuery.docs.isEmpty) {
      final samplePet = Pet(
        id: '', // Firestore will generate an ID.
        ownerId: user.uid,
        name: 'Buddy',
        species: 'Dog',
        about: 'A friendly golden retriever who loves walks.',
        avatarUrl: null,
      );
      await db.collection('pets').add(samplePet.toMap()..remove('id'));
    }

    // Retrieve the pet ID we just created (or the existing one) for further seeding.
    String petId;
    final petSnap = await db.collection('pets').where('ownerId', isEqualTo: user.uid).limit(1).get();
    if (petSnap.docs.isNotEmpty) {
      petId = petSnap.docs.first.id;
    } else {
      petId = '';
    }

    // ---- Seed Events ----
    final eventsSnap = await db.collection('events').limit(1).get();
    if (eventsSnap.docs.isEmpty) {
      final sampleEvent = Event(
        id: '',
        organizerId: user.uid,
        title: 'Community Dog Walk',
        description: 'Join us for a friendly dog walk in the park. All breeds welcome!',
        location: const GeoPoint(37.7749, -122.4194), // San Francisco example
        address: 'Golden Gate Park, San Francisco, CA',
        dateTime: DateTime.now().add(const Duration(days: 2)),
        imageUrl: null,
        attendeeCount: 0,
      );
      await db.collection('events').add(sampleEvent.toMap()..remove('id'));
    }

    // ---- Seed Forum Topics ----
    final forumSnap = await db.collection('forum_topics').limit(1).get();
    if (forumSnap.docs.isEmpty) {
      final sampleTopic = ForumTopic(
        id: '',
        authorId: user.uid,
        title: 'Tips for First‑Time Dog Owners',
        description: 'What are the most important things to consider when adopting a new dog?',
        createdAt: DateTime.now(),
      );
      await db.collection('forum_topics').add(sampleTopic.toMap()..remove('id'));
    }

    // ---- Seed Lost Pet Reports ----
    final lostPetSnap = await db.collection('lost_pets').limit(1).get();
    if (lostPetSnap.docs.isEmpty) {
      final sampleReport = LostPetReport(
        id: '',
        reporterId: user.uid,
        petName: 'Buddy',
        species: 'Dog',
        breed: 'Golden Retriever',
        lastKnownLocation: 'Central Park, NY',
        contactInfo: '555‑1234',
        // Use a placeholder image URL so the UI shows an image.
        photoUrl: 'https://picsum.photos/seed/lostpet/600/400',
        isFound: false,
        createdAt: DateTime.now(),
      );
      // Store the report without overriding the concrete DateTime.
      await db.collection('lost_pets').add(sampleReport.toMap()..remove('id'));
    }

    // ---- Seed Vaccinations for the sample pet ----
    if (petId.isNotEmpty) {
      final vacSnap = await db.collection('vaccinations').where('petId', isEqualTo: petId).limit(1).get();
      if (vacSnap.docs.isEmpty) {
        final sampleVac = Vaccination(
          id: '',
          petId: petId,
          name: 'Rabies',
          dateAdministered: DateTime.now().subtract(const Duration(days: 365)),
          isPublic: true,
        );
        await db.collection('vaccinations').add(sampleVac.toMap()..remove('id'));
      }
    }

    // ---- Seed Posts (optional) ----
    // Add a simple post if none exist.
    final postSnap = await db.collection('posts').limit(1).get();
    if (postSnap.docs.isEmpty) {
      final samplePost = Post(
        id: '',
        authorId: user.uid,
        // Placeholder image so the feed displays an image.
        mediaUrl: 'https://picsum.photos/seed/pawst/600/400',
        caption: 'Welcome to Pawst! This is a sample post.',
        createdAt: DateTime.now(),
      );
      await db.collection('posts').add(samplePost.toMap()..remove('id'));
    }
  }
}
