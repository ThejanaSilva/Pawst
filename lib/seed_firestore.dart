<<<<<<< HEAD
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSeed {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔥 RUN THIS ONCE ONLY
  static Future<void> seedAll() async {
    await seedUsers();
    await seedPets();
    await seedPosts();
    await seedLostPets();
  }

  // ---------------- USERS ----------------
  static Future<void> seedUsers() async {
    final users = [
      {
        "id": "user_1",
        "name": "Alice",
        "username": "alice",
        "profilePic": "https://i.pravatar.cc/150?img=1",
      },
      {
        "id": "user_2",
        "name": "Emma",
        "username": "emma",
        "profilePic": "https://i.pravatar.cc/150?img=2",
      },
    ];

    for (var user in users) {
      await _db.collection("users").doc(user["id"]).set(user);
    }
  }

  // ---------------- PETS ----------------
  static Future<void> seedPets() async {
    final pets = [
      {
        "id": "pet_1",
        "ownerId": "user_1",
        "name": "Charlie",
        "breed": "Golden Retriever",
        "ageYears": 3,
        "weightKg": 25,
        "imageUrl": "https://images.unsplash.com/photo-1552053831-71594a27632d",
      },
      {
        "id": "pet_2",
        "ownerId": "user_2",
        "name": "Luna",
        "breed": "Husky",
        "ageYears": 2,
        "weightKg": 20,
        "imageUrl":
            "https://images.unsplash.com/photo-1605568427561-40dd23c2acea",
      },
    ];

    for (var pet in pets) {
      await _db.collection("pets").doc(pet["id"] as String).set(pet);
    }
  }

  // ---------------- POSTS ----------------
  static Future<void> seedPosts() async {
    final posts = [
      {
        "id": "post_1",
        "authorId": "user_1",
        "username": "alice",
        "imageUrl":
            "https://images.unsplash.com/photo-1517423440428-a5a00ad493e8",
        "caption": "Charlie enjoyed the park today 🐶",
        "paws": 12,
        "isPawed": false,
        "isBookmarked": false,
        "createdAt": FieldValue.serverTimestamp(),
        "comments": [
          {"username": "emma", "text": "So cute!", "replies": []}
        ]
      },
      {
        "id": "post_2",
        "authorId": "user_2",
        "username": "emma",
        "imageUrl": "https://images.unsplash.com/photo-1548199973-03cce0bbc87b",
        "caption": "My sleepy husky ❤️",
        "paws": 8,
        "isPawed": false,
        "isBookmarked": false,
        "createdAt": FieldValue.serverTimestamp(),
        "comments": []
      },
    ];

    for (var post in posts) {
      await _db.collection("posts").doc(post["id"] as String).set(post);
    }
  }

  // ---------------- LOST PETS ----------------
  static Future<void> seedLostPets() async {
    final reports = [
      {
        "id": "lost_1",
        "reporterId": "user_1",
        "petName": "Buddy",
        "species": "Dog",
        "breed": "Golden Retriever",
        "lastKnownLocation": "Central Park",
        "contactInfo": "+1 555 1234",
        "photoUrl":
            "https://images.unsplash.com/photo-1517849845537-4d257902454a",
        "description":
            "Friendly dog wearing a blue collar. Missing since yesterday.",
        "reward": 100,
        "isFound": false,
        "createdAt": FieldValue.serverTimestamp(),
      },
      {
        "id": "lost_2",
        "reporterId": "user_2",
        "petName": "Mittens",
        "species": "Cat",
        "breed": "Siamese",
        "lastKnownLocation": "5th Avenue",
        "contactInfo": "+1 555 5678",
        "photoUrl":
            "https://images.unsplash.com/photo-1519052537078-e6302a4968d4",
        "description": "White Siamese cat. Green eyes. Very shy.",
        "reward": 50,
        "isFound": false,
        "createdAt": FieldValue.serverTimestamp(),
      }
    ];

    for (var report in reports) {
      await _db.collection("lost_pets").doc(report["id"] as String).set(report);
    }
  }
  static Future<void> seedForumTopics() async {
    final topics = [
      {
        "id": "topic_1",
        "authorId": "user_1",
        "title": "My Golden Retriever keeps scratching. Is this normal?",
        "description":
            "Charlie scratches constantly near his ears. Could this be allergies?",
        "replyCount": 2,
        "hasVetReply": true,
        "createdAt": FieldValue.serverTimestamp(),
      },
      {
        "id": "topic_2",
        "authorId": "user_2",
        "title": "Puppy refuses to eat dry food",
        "description":
            "Luna only eats treats and ignores her meals. Any advice?",
        "replyCount": 1,
        "hasVetReply": false,
        "createdAt": FieldValue.serverTimestamp(),
      }
    ];

    for (var topic in topics) {
      await _db
          .collection("forum_topics")
          .doc(topic["id"] as String)
          .set(topic);
    }
  }
  static Future<void> seedForumComments() async {
    final comments = [
      {
        "topicId": "topic_1",
        "authorId": "user_2",
        "text": "My dog had the same issue. Turned out to be allergies.",
        "isVetResponse": false,
        "createdAt": FieldValue.serverTimestamp(),
      },
      {
        "topicId": "topic_1",
        "authorId": "vet_1",
        "text":
            "Persistent scratching may indicate ear infection or allergies. I recommend a checkup.",
        "isVetResponse": true,
        "createdAt": FieldValue.serverTimestamp(),
      },
      {
        "topicId": "topic_2",
        "authorId": "user_1",
        "text": "Try mixing wet food gradually.",
        "isVetResponse": false,
        "createdAt": FieldValue.serverTimestamp(),
      }
    ];

    for (var comment in comments) {
      await _db.collection("forum_comments").add(comment);
=======
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
>>>>>>> origin/dev_wta_v2
    }
  }
}
