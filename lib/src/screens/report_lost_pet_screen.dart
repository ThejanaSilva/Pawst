import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firestore_service.dart';
import '../services/cloudinary_service.dart';
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
    // Validation
    if (_nameCtrl.text.trim().isEmpty ||
        _locationCtrl.text.trim().isEmpty ||
        _contactCtrl.text.trim().isEmpty) {
      _showMessage(
        "Pet name, location, and contact info are required.",
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      String photoUrl = "";

      // Upload image to Cloudinary
      if (_mediaFile != null) {
        photoUrl = await CloudinaryService.uploadImage(_mediaFile!);
      }

      // Save report to Firestore
      await FirestoreService.addLostPetReport(
        LostPetReport(
          id: '',
          reporterId:
              "user_1", // replace later with AuthService.currentUser!.uid
          petName: _nameCtrl.text.trim(),
          species: _speciesCtrl.text.trim(),
          breed: _breedCtrl.text.trim(),
          lastKnownLocation: _locationCtrl.text.trim(),
          contactInfo: _contactCtrl.text.trim(),
          photoUrl: photoUrl,
          createdAt: DateTime.now(),
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lost pet report posted successfully"),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint("Error posting report: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to post report: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
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
