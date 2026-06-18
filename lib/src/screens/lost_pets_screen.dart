import 'package:flutter/material.dart';
import '../models/lost_pet_report.dart';
import '../services/firestore_service.dart';
import 'report_lost_pet_screen.dart';

class LostPetsScreen extends StatelessWidget {
  const LostPetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lost Pets Hub')),
      body: StreamBuilder<List<LostPetReport>>(
        stream: FirestoreService.streamLostPets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load lost pets.'));
          }
          final reports = snapshot.data ?? [];
          if (reports.isEmpty) {
            return const Center(child: Text('No lost pets reported in your area.'));
          }
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
                      Image.network(report.photoUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${report.petName} (${report.species})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportLostPetScreen()));
        },
        icon: const Icon(Icons.campaign),
        backgroundColor: Colors.redAccent,
        label: const Text('Report Lost Pet'),
      ),
    );
  }
}

