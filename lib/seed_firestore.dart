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
    }
  }
}
