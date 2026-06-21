import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'pet_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    if (user == null) {
      return const Center(child: Text('Not signed in'));
    }
    return StreamBuilder<List<Pet>>(
      stream: FirestoreService.streamUserPets(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading pets'));
        }
        final pets = snapshot.data ?? [];
        if (pets.isEmpty) {
          return const Center(child: Text('No pets added yet'));
        }
        // Show the first pet's profile for now.
        final pet = pets.first;
        return PetProfileScreen(pet: pet);
      },
    );
  }
}
