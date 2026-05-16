import 'package:flutter/material.dart';
import 'src/screens/auth_screen.dart';
import 'src/screens/feed_screen.dart';
import 'src/services/auth_service.dart';
import 'src/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.init();
  runApp(PawstApp());
}

class PawstApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pawst!',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data != null) {
          return FeedScreen();
        }
        return AuthScreen();
      },
    );
  }
}
