import 'package:flutter/material.dart';
import 'feed_screen.dart';
import 'pet_profile_screen.dart'; // Import PetProfileScreen

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
    PetProfileScreen(),
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
