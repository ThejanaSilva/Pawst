import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/event.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late bool _isAttending;
  late int _rsvpCount;

  @override
  void initState() {
    super.initState();
    final user = AuthService.currentUser;
    _isAttending = user != null && widget.event.attendeeCount > 0; // simplified check
    _rsvpCount = widget.event.attendeeCount;
  }

  Future<void> _toggleRsvp() async {
    final user = AuthService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in to RSVP.')));
      return;
    }
    final newAttending = !_isAttending;
    setState(() {
      _isAttending = newAttending;
      _rsvpCount += newAttending ? 1 : -1;
    });
    try {
      await FirestoreService.toggleRsvp(widget.event.id, user.uid, newAttending);
    } catch (e) {
      // Revert on error
      setState(() {
        _isAttending = !newAttending;
        _rsvpCount += !newAttending ? 1 : -1;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to RSVP: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.event.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.teal),
                const SizedBox(width: 8),
                Text(widget.event.dateTime.toString().split('.')[0] , style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.teal),
                const SizedBox(width: 8),
                Text(widget.event.address, style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            // Map view of the event location
            SizedBox(
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  // Updated for flutter_map 8.x: use initialCenter and initialZoom
                  initialCenter: LatLng(widget.event.location.latitude, widget.event.location.longitude),
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.pawst_app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(widget.event.location.latitude, widget.event.location.longitude),
                        width: 40,
                        height: 40,
                        // Updated for flutter_map 8.x: use 'child' instead of 'builder'
                        child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.people, color: Colors.teal),
                const SizedBox(width: 8),
                Text('$_rsvpCount attending', style: const TextStyle(fontSize: 16)),
              ],
            ),
            const Divider(height: 32),
            const Text('About this event', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.event.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 48),
            Center(
              child: ElevatedButton(
                onPressed: _toggleRsvp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAttending ? Colors.redAccent : Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                ),
                child: Text(_isAttending ? 'Cancel RSVP' : 'RSVP Now', style: const TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
