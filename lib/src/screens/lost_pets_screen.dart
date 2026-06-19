import 'package:flutter/material.dart';
import '../models/lost_pet_report.dart';
// import '../services/firestore_service.dart'; // Commented out: using hardcoded data for UI testing
import 'report_lost_pet_screen.dart';

class LostPetsScreen extends StatelessWidget {
  const LostPetsScreen({super.key});

  // Hardcoded sample data for UI preview. Replace with real data from Firestore later.
  static final List<LostPetReport> _hardcodedReports = [
    LostPetReport(
      id: '1',
      reporterId: 'user1',
      petName: 'Buddy',
      species: 'Dog',
      breed: 'Golden Retriever',
      lastKnownLocation: 'Central Park',
      contactInfo: '555-1234',
      photoUrl: '',
      createdAt: DateTime.now(),
    ),
    LostPetReport(
      id: '2',
      reporterId: 'user2',
      petName: 'Mittens',
      species: 'Cat',
      breed: 'Siamese',
      lastKnownLocation: '5th Avenue',
      contactInfo: '555-5678',
      photoUrl: '',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lost Pets Hub')),
      // Hardcoded data for UI testing. Replace with StreamBuilder when connecting to Firestore.
      body: ListView.builder(
        itemCount: _hardcodedReports.length,
        itemBuilder: (context, i) {
          final report = _hardcodedReports[i];
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
                  Image.network(report.photoUrl,
                      height: 200, width: double.infinity, fit: BoxFit.cover),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(report.petName,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const Text('LOST',
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(report.breed, style: const TextStyle(fontSize: 16)),
                      Text(report.lastKnownLocation,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(report.contactInfo,
                          style:
                              TextStyle(fontSize: 16, color: Colors.blue[800])),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ReportLostPetScreen()));
        },
        icon: const Icon(Icons.campaign),
        backgroundColor: Colors.redAccent,
        label: const Text('Report Lost Pet'),
      ),
    );
  }
}
