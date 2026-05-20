import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'event_detail_screen.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});


  void _showNewEventDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Meetup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Event Title')),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
            TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Location')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              final user = AuthService.currentUser;
              if (user == null) return;

              await FirestoreService.addEvent(
                Event(
                  id: '',
                  organizerId: user.uid,
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  location: locCtrl.text.trim(),
                  // Default event date 1 day from now
                  eventDate: DateTime.now().add(const Duration(days: 1)),
                  createdAt: DateTime.now(),
                )
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
                      Text('📅 ${event.eventDate.toString().split(' ')[0]}'),
                      Text('📍 ${event.location}'),
                      const SizedBox(height: 4),
                      Text('${event.rsvps.length} attending', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
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
