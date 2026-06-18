import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Simple screen to verify Firestore connectivity.
///
/// It writes a test document to the `test/ping` path and then reads it back.
/// All results are printed to the debug console via `debugPrint`.
class FirestoreTestScreen extends StatelessWidget {
  const FirestoreTestScreen({Key? key}) : super(key: key);

  Future<void> _writeTestDoc() async {
    try {
      await FirebaseFirestore.instance
          .collection('test')
          .doc('ping')
          .set({'timestamp': FieldValue.serverTimestamp()});
      debugPrint('✅ Write succeeded');
    } catch (e) {
      debugPrint('❌ Write failed: $e');
    }
  }

  Future<void> _readTestDoc() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('test')
          .doc('ping')
          .get();
      if (snap.exists) {
        debugPrint('✅ Read succeeded: ${snap.data()}');
      } else {
        debugPrint('⚠️ Document does not exist');
      }
    } catch (e) {
      debugPrint('❌ Read failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Firestore connectivity test')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('User: ${user?.uid ?? "not signed‑in"}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _writeTestDoc,
              child: const Text('Write test document'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _readTestDoc,
              child: const Text('Read test document'),
            ),
          ],
        ),
      ),
    );
  }
}
