import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSeed {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔥 RUN THIS ONCE ONLY
  static Future<void> seedAll() async {
    await seedUsers();
    await seedPets();
    await seedPosts();
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
}
