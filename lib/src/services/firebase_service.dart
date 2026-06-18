import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // for debugPrint
import '../../firebase_options.dart';

class FirebaseService {
  static Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Ensure the user is signed in (anonymous) so Firestore rules that require authentication succeed.
    // This is safe for development and testing environments.
    try {
      // If no user is currently signed in, sign in anonymously.
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
    } catch (e) {
      // Log the error but do not crash the app; the UI will show unauthenticated state.
      debugPrint('⚠️ Anonymous sign‑in failed: $e');
    }
  }
}
