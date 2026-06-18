import 'package:flutter/material.dart';
import 'src/screens/auth_screen.dart';
import 'src/screens/feed_screen.dart';
import 'src/screens/lost_pets_screen.dart';
import 'src/screens/forum_screen.dart';
import 'src/screens/events_screen.dart';
import 'src/screens/chat_rooms_screen.dart';
import 'src/services/auth_service.dart';
import 'src/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.init();
  runApp(const PawstApp());
}

class PawstApp extends StatelessWidget {
  const PawstApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pawst!',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const AuthGate(),
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
  final _screens = [const FeedScreen(), const LostPetsScreen(), const ForumScreen(), const EventsScreen(), const ChatRoomsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        type: BottomNavigationBarType.fixed, // Added this since > 3 items requires fixed type to show colors properly
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _idx = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Lost Pets'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Forum'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Chats'),
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
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data != null) {
          return const MainHomeScreen(); // Replaced FeedScreen directly with MainHomeScreen
        }
        return const AuthScreen();
      },
    );
  }
}
