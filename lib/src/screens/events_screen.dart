import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'event_detail_screen.dart';

class EventsScreen extends StatelessWidget {

  void _showNewEventDialog(BuildContext context) {
    final _titleCtrl = TextEditingController();
    final _descCtrl = TextEditingController();
    final _locCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Create Meetup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleCtrl, decoration: InputDecoration(labelText: 'Event Title')),
            TextField(controller: _descCtrl, decoration: InputDecoration(labelText: 'Description'), maxLines: 2),
            TextField(controller: _locCtrl, decoration: InputDecoration(labelText: 'Location')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (_titleCtrl.text.trim().isEmpty) return;
              final user = AuthService.currentUser;
              if (user == null) return;

              await FirestoreService.addEvent(
                Event(
                  id: '',
                  organizerId: user.uid,
                  title: _titleCtrl.text.trim(),
                  description: _descCtrl.text.trim(),
                  location: _locCtrl.text.trim(),
                  // Default event date 1 day from now
                  eventDate: DateTime.now().add(Duration(days: 1)),
                  createdAt: DateTime.now(),
                )
              );
              Navigator.pop(ctx);
            },
            child: Text('Create'),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Events & Meetups')),
      body: StreamBuilder<List<Event>>(
        stream: FirestoreService.streamEvents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final events = snapshot.data!;
          if (events.isEmpty) return Center(child: Text('No upcoming events.'));

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  title: Text(event.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text('📅 ${event.eventDate.toString().split(' ')[0]}'),
                      Text('📍 ${event.location}'),
                      SizedBox(height: 4),
                      Text('${event.rsvps.length} attending', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
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
        child: Icon(Icons.add_location_alt),
        tooltip: 'Create Event',
      ),
    );
  }
}
