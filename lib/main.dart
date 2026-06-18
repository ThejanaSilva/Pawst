import 'package:flutter/material.dart';
import 'src/screens/auth_screen.dart';
import 'src/screens/feed_screen.dart';
import 'src/screens/lost_pets_screen.dart';
import 'src/screens/forum_screen.dart';
import 'src/screens/events_screen.dart';
import 'src/screens/chat_rooms_screen.dart';
import 'src/screens/firestore_test_screen.dart'; // added for connectivity test
import 'src/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added for User type
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
    // Temporary simple home to verify UI rendering.
    return MaterialApp(
      title: 'Pawst!',
      theme: ThemeData(primarySwatch: Colors.teal),
      // Use AuthGate to handle authentication flow and then show the main UI.
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
    debugPrint('🔎 Building MainHomeScreen');
    // Debug container to verify UI rendering. Replace the normal screen body with a solid red box.
    return Scaffold(
      // Show the currently selected screen from the list.
      body: _screens[_idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        type: BottomNavigationBarType.fixed,
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
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges(),
      builder: (context, snapshot) {
        // Log snapshot state for debugging.
        debugPrint('🔎 AuthGate snapshot: connection=${snapshot.connectionState}, hasData=${snapshot.hasData}, error=${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Auth error: ${snapshot.error}')));
        }
        if (snapshot.data != null) {
          // User is signed in – navigate to the main home screen.
          return const MainHomeScreen();
        }
        // No user signed in – show the auth screen.
        return const AuthScreen();
      },
    );
  }
}
