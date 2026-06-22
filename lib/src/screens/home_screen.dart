import 'package:flutter/material.dart';
import 'feed_screen.dart';
import 'pet_profile_screen.dart'; // Import PetProfileScreen
import '../models/pet.dart'; // Import Pet model for placeholder

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  // Updated to use PetProfileScreen instead of undefined ProfileScreen
  final pages = const [
    FeedScreen(),
    // Provide a placeholder Pet instance to satisfy the required 'pet' parameter.
    PetProfileScreen(
      pet: Pet(
        id: '',
        ownerId: '',
        name: 'Placeholder',
        species: 'Dog',
        breed: 'Mixed',
        gender: 'Male',
        bio: '',
        about: '',
        imageUrl: '',
        weightKg: 0.0,
        ageYears: 0,
        friendlinessLevel: 3,
        goodWithDogs: true,
        goodWithCats: true,
        goodWithChildren: true,
        vaccinationPdfName: '',
        vaccinations: [],
        appointments: [],
        healthRecords: [],
      ),
      isOwner: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Feed"),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: "Pet"),
        ],
      ),
    );
  }
}
