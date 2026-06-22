import 'package:flutter/material.dart';
import '../models/lost_pet_report.dart';
import '../services/firestore_service.dart'; // Using FirestoreService for real data
import 'report_lost_pet_screen.dart';

/// Screen that displays a list of lost pet reports.
///
/// It streams the reports from Firestore and handles the following UI states:
///   * Loading – shows a progress indicator.
///   * Data – shows a list of cards when reports are available.
///   * Empty – shows a friendly message when there are no reports.
///   * Error – shows an error message when the stream fails.
class LostPetsScreen extends StatelessWidget {
  const LostPetsScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lost Pets Hub')),
      body: StreamBuilder<List<LostPetReport>>(
        stream: FirestoreService.streamLostPets(),
        builder: (context, snapshot) {
          // Loading state.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Extract the list safely – default to empty.
          final reports = snapshot.data ?? [];

          // If we have data, show it.
          if (reports.isNotEmpty) {
            return ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, i) {
                final report = reports[i];
                return Card(
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.redAccent, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (report.photoUrl.isNotEmpty)
                        Image.network(
                          report.photoUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${report.petName} (${report.species})',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const Text('LOST', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Breed: ${report.breed}', style: const TextStyle(fontSize: 16)),
                            Text('Last seen: ${report.lastKnownLocation}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Contact: ${report.contactInfo}', style: TextStyle(fontSize: 16, color: Colors.blue[800])),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }

          // No data or error handling.
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load lost pets.'));
          }
          return const Center(child: Text('No lost pets reported in your area.'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportLostPetScreen())),
        icon: const Icon(Icons.campaign),
        backgroundColor: Colors.redAccent,
        label: const Text('Report Lost Pet'),
      ),
    );
  }
}
