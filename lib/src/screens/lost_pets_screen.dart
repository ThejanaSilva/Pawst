import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'report_lost_pet_screen.dart';

class LostPetsScreen extends StatelessWidget {
  const LostPetsScreen({super.key});

  Stream<QuerySnapshot> _streamLostPets() {
    return FirebaseFirestore.instance
        .collection('lost_pets')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      // ================= APP BAR =================
      appBar: AppBar(
        title: const Text("Lost Pets Hub"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      // ================= BODY =================
      body: StreamBuilder<QuerySnapshot>(
        stream: _streamLostPets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No lost pets reported 🐾",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;

              final photo = data['photoUrl'] ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= IMAGE =================
                    if (photo.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.network(
                          photo,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        height: 180,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEDEFF5),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.pets, size: 60, color: Colors.grey),
                        ),
                      ),

                    // ================= CONTENT =================
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TITLE ROW
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  data['petName'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "LOST",
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // BREED + SPECIES
                          Text(
                            "${data['species'] ?? ''} • ${data['breed'] ?? ''}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // LOCATION
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 18, color: Colors.redAccent),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  data['lastKnownLocation'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // CONTACT
                          Row(
                            children: [
                              const Icon(Icons.phone,
                                  size: 18, color: Colors.blue),
                              const SizedBox(width: 6),
                              Text(
                                data['contactInfo'] ?? '',
                                style: TextStyle(
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // TIME
                          if (data['createdAt'] != null)
                            Text(
                              _formatTime(data['createdAt']),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
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

      // ================= FLOATING BUTTON =================
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(.4),
              blurRadius: 15,
            )
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.redAccent,
          icon: const Icon(Icons.campaign,color: Colors.white,),
          label: const Text(
            "Report Missing Pet",
            style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ReportLostPetScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  // ================= TIME FORMAT =================
  String _formatTime(dynamic timestamp) {
    try {
      final dt = (timestamp as Timestamp).toDate();
      final diff = DateTime.now().difference(dt);

      if (diff.inDays > 0) return "${diff.inDays}d ago";
      if (diff.inHours > 0) return "${diff.inHours}h ago";
      if (diff.inMinutes > 0) return "${diff.inMinutes}m ago";
      return "just now";
    } catch (_) {
      return "";
    }
  }
}
