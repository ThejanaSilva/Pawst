import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // for debugPrint
import '../../firebase_options.dart';

class FirebaseService {
  static Future<void> init() async {
    // On web we need to provide explicit Firebase options; on mobile platforms the
    // configuration is read from the generated google‑services files, so we can
    // initialise without passing options.
    try {
      if (kIsWeb) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } else {
        await Firebase.initializeApp();
      }
      debugPrint('✅ Firebase initialized');
    } catch (e) {
      // Log the initialization error but do not rethrow to prevent the app from crashing.
      // The UI will handle the lack of Firebase by showing the auth screen.
      debugPrint('❌ Firebase initialization failed: $e');
    }
    // Ensure the user is signed in (anonymous) so Firestore rules that require authentication succeed.
    // This is safe for development and testing environments.
    try {
      // If no user is currently signed in, sign in anonymously.
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
        debugPrint('✅ Anonymous sign‑in succeeded');
      } else {
        debugPrint('ℹ️ User already signed in: ${FirebaseAuth.instance.currentUser?.uid}');
      }
    } catch (e) {
      // Log the error but do not crash the app; the UI will show unauthenticated state.
      debugPrint('⚠️ Anonymous sign‑in failed: $e');
    }
  }
}
