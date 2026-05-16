import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

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
    _isAttending = user != null && widget.event.rsvps.contains(user.uid);
    _rsvpCount = widget.event.rsvps.length;
  }

  Future<void> _toggleRsvp() async {
    final user = AuthService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please sign in to RSVP.')));
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
      appBar: AppBar(title: Text('Event Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.event.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.teal),
                SizedBox(width: 8),
                Text(widget.event.eventDate.toString().split('.')[0] , style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.teal),
                SizedBox(width: 8),
                Text(widget.event.location, style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.people, color: Colors.teal),
                SizedBox(width: 8),
                Text('$_rsvpCount attending', style: TextStyle(fontSize: 16)),
              ],
            ),
            Divider(height: 32),
            Text('About this event', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(widget.event.description, style: TextStyle(fontSize: 16)),
            SizedBox(height: 48),
            Center(
              child: ElevatedButton(
                onPressed: _toggleRsvp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAttending ? Colors.redAccent : Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                ),
                child: Text(_isAttending ? 'Cancel RSVP' : 'RSVP Now', style: TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
