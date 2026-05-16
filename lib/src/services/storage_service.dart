import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String> uploadPostMedia({required File file, required String userId}) async {
    final fileName = file.path.split(RegExp(r'[\\/]+')).last;
    final ext = fileName.contains('.') ? fileName.split('.').last : 'jpg';
    final ts = DateTime.now().millisecondsSinceEpoch;
    final ref = _storage.ref().child('posts/$userId/$ts.$ext');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
