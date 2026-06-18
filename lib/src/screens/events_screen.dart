// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, no_leading_underscores_for_local_identifiers
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart'; // for reverse geocoding
import '../models/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'event_detail_screen.dart';
import 'location_picker_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});


  void _showNewEventDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    GeoPoint? selectedGeoPoint;
    File? selectedImageFile;

    // Use a StatefulBuilder to manage loading state inside the dialog.
    bool isUploading = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Create Meetup'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Event Title')),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
              // Address input with optional map picker
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: locCtrl,
                      decoration: const InputDecoration(labelText: 'Address'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.map),
                    tooltip: 'Pick on map',
                    onPressed: () async {
                      final result = await Navigator.of(context).push<GeoPoint>(
                        MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
                      );
                      if (result != null) {
                        selectedGeoPoint = result;
                        // Reverse‑geocode to a readable address.
                        try {
                          final placemarks = await placemarkFromCoordinates(result.latitude, result.longitude);
                          if (placemarks.isNotEmpty) {
                            final place = placemarks.first;
                            final address = '${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}'.replaceAll(' ,', ',').trim();
                            locCtrl.text = address;
                          } else {
                            locCtrl.text = '${result.latitude.toStringAsFixed(5)}, ${result.longitude.toStringAsFixed(5)}';
                          }
                        } catch (_) {
                          locCtrl.text = '${result.latitude.toStringAsFixed(5)}, ${result.longitude.toStringAsFixed(5)}';
                        }
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo),
                    tooltip: 'Add image',
                    onPressed: () async {
                      final picker = ImagePicker();
                      final XFile? picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                      if (picked != null) {
                        selectedImageFile = File(picked.path);
                      }
                    },
                  ),
                ],
              ),
              if (isUploading) const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator()),
            ],
          ),
            actions: [
            TextButton(onPressed: isUploading ? null : () => Navigator.pop(dialogContext), child: const Text('Cancel')),
                      ElevatedButton(
                onPressed: isUploading
                  ? null
                  : () async {
                      if (titleCtrl.text.trim().isEmpty) return;
                      final user = AuthService.currentUser;
                      if (user == null) return;
                      setState(() => isUploading = true);
                      String? imageUrl;
                      try {
                        // Upload image if selected
                        if (selectedImageFile != null) {
                          final storageRef = FirebaseStorage.instance.ref()
                              .child('event_images')
                              .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
                          await storageRef.putFile(selectedImageFile!);
                          imageUrl = await storageRef.getDownloadURL();
                        }
                        // Add event to Firestore
                        await FirestoreService.addEvent(
                          Event(
                            id: '',
                            organizerId: user.uid,
                            title: titleCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            address: locCtrl.text.trim(),
                            location: selectedGeoPoint ?? const GeoPoint(0, 0),
                            dateTime: DateTime.now().add(const Duration(days: 1)),
                            imageUrl: imageUrl,
                          ),
                        );
                      } catch (e, stack) {
                        // Log error and inform user
                        debugPrint('Create event error: $e\n$stack');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to create event: $e')),
                        );
                      } finally {
                        // Reset loading state and close dialog
                        setState(() => isUploading = false);
                        Navigator.pop(dialogContext);
                      }
                    },
                child: const Text('Create'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events & Meetups')),
      body: StreamBuilder<List<Event>>(
        stream: FirestoreService.streamEvents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final events = snapshot.data!;
          if (events.isEmpty) return const Center(child: Text('No upcoming events.'));

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('📅 ${event.dateTime.toString().split(' ')[0]}'),
                      Text('📍 ${event.address}'),
                      const SizedBox(height: 4),
                      Text('${event.attendeeCount} attending', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)));
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewEventDialog(context),
        tooltip: 'Create Event',
        child: const Icon(Icons.add_location_alt),
      ),
    );
  }
}
