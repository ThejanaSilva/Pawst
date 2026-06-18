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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
                      // Perform reverse geocoding to obtain a human‑readable address.
                      try {
                        final placemarks = await placemarkFromCoordinates(result.latitude, result.longitude);
                        if (placemarks.isNotEmpty) {
                          final place = placemarks.first;
                          final address = '${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}'.replaceAll(' ,', ',').trim();
                          locCtrl.text = address;
                        } else {
                          // Fallback to coordinates if no placemark found.
                          locCtrl.text = '${result.latitude.toStringAsFixed(5)}, ${result.longitude.toStringAsFixed(5)}';
                        }
                      } catch (e) {
                        // On error, show coordinates.
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
                    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      selectedImageFile = File(picked.path);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              final user = AuthService.currentUser;
              if (user == null) return;

              String? imageUrl;
              if (selectedImageFile != null) {
                final storageRef = FirebaseStorage.instance.ref()
                    .child('event_images')
                    .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
                await storageRef.putFile(selectedImageFile!);
                imageUrl = await storageRef.getDownloadURL();
              }
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
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          )
        ],
      )
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
