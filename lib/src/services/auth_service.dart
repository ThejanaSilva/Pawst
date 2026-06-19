import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static User? get user => _auth.currentUser;

  /// Alias used across the app screens
  static User? get currentUser => _auth.currentUser;

  static Stream<User?> authChanges() {
    return _auth.authStateChanges();
  }

  /// Alias used by main.dart AuthGate
  static Stream<User?> authStateChanges() => authChanges();

  static Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with email & password (alias used by AuthScreen)
  static Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with email & password
  static Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in anonymously for prototyping
  static Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }
}
