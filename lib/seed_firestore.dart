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
      return;
    }
    final db = FirebaseFirestore.instance;

    // Seed Pets
    final petQuery = await db.collection('pets').where('ownerId', isEqualTo: user.uid).limit(1).get();
    if (petQuery.docs.isEmpty) {
      // Provide all required fields for the Pet model with sensible placeholder values.
      final samplePet = Pet(
        id: '',
        ownerId: user.uid,
        name: 'Buddy',
        species: 'Dog',
        breed: 'Golden Retriever',
        gender: 'Male',
        bio: 'A friendly golden retriever who loves walks.',
        about: 'A friendly golden retriever who loves walks.',
        imageUrl: '',
        weightKg: 10.0,
        ageYears: 3,
        friendlinessLevel: 5,
        goodWithDogs: true,
        goodWithCats: true,
        goodWithChildren: true,
        vaccinationPdfName: '',
        vaccinations: [],
        appointments: [],
        healthRecords: [],
      );
      await db.collection('pets').add(samplePet.toMap()..remove('id'));
    }

    // Retrieve the pet ID for further seeding
    String petId;
    final petSnap = await db.collection('pets').where('ownerId', isEqualTo: user.uid).limit(1).get();
    if (petSnap.docs.isNotEmpty) {
      petId = petSnap.docs.first.id;
    } else {
      petId = '';
    }

    // Seed Events
    final eventsSnap = await db.collection('events').limit(1).get();
    if (eventsSnap.docs.isEmpty) {
      final sampleEvent = Event(
        id: '',
        organizerId: user.uid,
        title: 'Community Dog Walk',
        description: 'Join us for a friendly dog walk in the park. All breeds welcome!',
        location: const GeoPoint(37.7749, -122.4194),
        address: 'Golden Gate Park, San Francisco, CA',
        dateTime: DateTime.now().add(const Duration(days: 2)),
        imageUrl: null,
        attendeeCount: 0,
      );
      await db.collection('events').add(sampleEvent.toMap()..remove('id'));
    }

    // Seed Forum Topics
    final forumSnap = await db.collection('forum_topics').limit(1).get();
    if (forumSnap.docs.isEmpty) {
      final sampleTopic = ForumTopic(
        id: '',
        authorId: user.uid,
        title: 'Tips for First-Time Dog Owners',
        description: 'What are the most important things to consider when adopting a new dog?',
        createdAt: DateTime.now(),
      );
      await db.collection('forum_topics').add(sampleTopic.toMap()..remove('id'));
    }

    // Seed Lost Pet Reports
    final lostPetSnap = await db.collection('lost_pets').limit(1).get();
    if (lostPetSnap.docs.isEmpty) {
      final sampleReport = LostPetReport(
        id: '',
        reporterId: user.uid,
        petName: 'Buddy',
        species: 'Dog',
        breed: 'Golden Retriever',
        lastKnownLocation: 'Central Park, NY',
        contactInfo: '555-1234',
        photoUrl: 'https://picsum.photos/seed/lostpet/600/400',
        isFound: false,
        createdAt: DateTime.now(),
      );
      await db.collection('lost_pets').add(sampleReport.toMap()..remove('id'));
    }

    // Seed Vaccinations
    if (petId.isNotEmpty) {
      final vacSnap = await db.collection('vaccinations').where('petId', isEqualTo: petId).limit(1).get();
      if (vacSnap.docs.isEmpty) {
        // Create a Vaccination entry for the pet.
        final vaccination = Vaccination(
          id: '',
          name: 'Rabies',
          date: DateTime.now().subtract(const Duration(days: 365)),
          completed: true,
        );
        await db.collection('vaccinations').add(vaccination.toMap()..remove('id'));
        final postSnap = await db.collection('posts').limit(1).get();
    if (postSnap.docs.isEmpty) {
      // Create a Post using the current Post model fields.
      final samplePost = Post(
        id: '',
        username: user.uid,
        imageUrl: 'https://picsum.photos/seed/pawst/600/400',
        caption: 'Welcome to Pawst! This is a sample post.',
        timeAgo: 'Just now',
        paws: 0,
        comments: [],
      );
      await db.collection('posts').add(samplePost.toMap()..remove('id'));
    }
  }
}
}
}
