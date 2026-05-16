import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class PostEditorScreen extends StatefulWidget {
  @override
  _PostEditorScreenState createState() => _PostEditorScreenState();
}

class _PostEditorScreenState extends State<PostEditorScreen> {
  final _captionCtrl = TextEditingController();
  File? _mediaFile;
  bool _isUploading = false;

  void _showMessage(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) {
      setState(() => _mediaFile = File(file.path));
    }
  }

  Future<void> _submit() async {
    final user = AuthService.currentUser;
    if (user == null) {
      _showMessage('You need to sign in first');
      return;
    }
    if (_mediaFile == null) {
      _showMessage('Please select a photo');
      return;
    }
    setState(() => _isUploading = true);
    try {
      final url = await StorageService.uploadPostMedia(file: _mediaFile!, userId: user.uid);
      await FirestoreService.createPost(authorId: user.uid, mediaUrl: url, caption: _captionCtrl.text.trim());
      _showMessage('Post uploaded');
      Navigator.pop(context);
    } catch (e) {
      _showMessage('Upload error: ${e.toString()}');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Pawst!')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _mediaFile == null
                ? Container(
                    height: 220,
                    color: Colors.grey[200],
                    child: Center(child: Text('No image selected')),
                  )
                : Image.file(_mediaFile!, height: 220, fit: BoxFit.cover),
            SizedBox(height: 12),
            TextField(
              controller: _captionCtrl,
              decoration: InputDecoration(labelText: 'Caption'),
              maxLines: 2,
            ),
            SizedBox(height: 12),
            OutlinedButton(onPressed: _pickImage, child: Text('Pick photo from gallery')),
            SizedBox(height: 12),
            _isUploading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(onPressed: _submit, child: Text('Post')),
          ],
        ),
      ),
    );
  }
}
