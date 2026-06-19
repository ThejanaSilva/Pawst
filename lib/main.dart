import 'package:flutter/material.dart';
import 'src/screens/auth_screen.dart';
import 'src/screens/feed_screen.dart';
import 'src/screens/lost_pets_screen.dart';
import 'src/screens/forum_screen.dart';
import 'src/screens/events_screen.dart';
import 'src/screens/chat_rooms_screen.dart';
import 'src/services/auth_service.dart';
import 'src/services/firebase_service.dart';
import 'src/screens/pet_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? initError;
  try {
    await FirebaseService.init();
  } catch (e) {
    initError = e;
  }

  runApp(PawstApp(initError: initError));
}

class PawstApp extends StatelessWidget {
  const PawstApp({super.key, this.initError});

  final Object? initError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pawst!',
      theme: ThemeData(primarySwatch: Colors.teal),
      home:
          initError == null ? const AuthGate() : ErrorScreen(error: initError!),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Startup Error')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Failed to initialize Firebase:\n$error',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  _MainHomeScreenState createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _idx = 0;
  final _screens = [
    const FeedScreen(),
    const LostPetsScreen(),
    const ForumScreen(),
    const EventsScreen(),
    const PetProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        type: BottomNavigationBarType
            .fixed, // Added this since > 3 items requires fixed type to show colors properly
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _idx = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Lost Pets'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Forum'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data != null) {
          return const MainHomeScreen(); // Replaced FeedScreen directly with MainHomeScreen
        }
        return const AuthScreen();
      },
    );
  }
}
