import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../models/lost_pet_report.dart';

class ReportLostPetScreen extends StatefulWidget {
  const ReportLostPetScreen({super.key});

  @override
  _ReportLostPetScreenState createState() => _ReportLostPetScreenState();
}

class _ReportLostPetScreenState extends State<ReportLostPetScreen> {
  final _nameCtrl = TextEditingController();
  final _speciesCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  
  File? _mediaFile;
  bool _isUploading = false;

  void _showMessage(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) {
      setState(() => _mediaFile = File(file.path));
    }
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _locationCtrl.text.trim().isEmpty || _contactCtrl.text.trim().isEmpty) {
      _showMessage('Name, location, and contact info are required');
      return;
    }
    
    final user = AuthService.currentUser;
    if (user == null) {
      _showMessage('You must be signed in to report a lost pet');
      return;
    }

    setState(() => _isUploading = true);
    try {
      String photoUrl = '';
      if (_mediaFile != null) {
        photoUrl = await StorageService.uploadLostPetPhoto(file: _mediaFile!, userId: user.uid);
      }

      await FirestoreService.addLostPetReport(
        LostPetReport(
          id: '',
          reporterId: user.uid,
          petName: _nameCtrl.text.trim(),
          species: _speciesCtrl.text.trim(),
          breed: _breedCtrl.text.trim(),
          lastKnownLocation: _locationCtrl.text.trim(),
          contactInfo: _contactCtrl.text.trim(),
          photoUrl: photoUrl,
          createdAt: DateTime.now(), // Ignored by firestore_service in favor of server timestamp
        )
      );
      
      _showMessage('Lost pet report posted successfully');
      Navigator.pop(context);
    } catch (e) {
      _showMessage('Error posting report: ${e.toString()}');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _speciesCtrl.dispose();
    _breedCtrl.dispose();
    _locationCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report a Lost Pet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                color: Colors.grey[200],
                child: _mediaFile == null
                    ? Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 40, color: Colors.grey[600]),
                          const SizedBox(height: 8),
                          const Text('Tap to add photo of the pet'),
                        ],
                      ))
                    : Image.file(_mediaFile!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Pet Name *')),
            TextField(controller: _speciesCtrl, decoration: const InputDecoration(labelText: 'Species (Dog, Cat, etc.)')),
            TextField(controller: _breedCtrl, decoration: const InputDecoration(labelText: 'Breed')),
            TextField(controller: _locationCtrl, decoration: const InputDecoration(labelText: 'Last Known Location *')),
            TextField(controller: _contactCtrl, decoration: const InputDecoration(labelText: 'Contact Information *', hintText: 'Phone number or email')),
            const SizedBox(height: 24),
            _isUploading 
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton.icon(
                  onPressed: _submit, 
                  icon: const Icon(Icons.campaign), 
                  label: const Text('Post Alert'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 16)
                  ),
                )
          ],
        ),
      ),
    );
  }
}
