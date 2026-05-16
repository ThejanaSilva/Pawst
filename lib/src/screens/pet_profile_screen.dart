import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/vaccination.dart';
import '../services/firestore_service.dart';

class PetProfileScreen extends StatelessWidget {
  final Pet pet;
  final bool isOwner;

  const PetProfileScreen({Key? key, required this.pet, this.isOwner = true}) : super(key: key);

  void _addVaccination(BuildContext context) {
    // A quick dialog to add a vaccination card entry
    final _nameCtrl = TextEditingController();
    bool _isPublic = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text('Add Vaccination'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'Vaccine Name')),
              SwitchListTile(
                title: Text('Make Public?'),
                value: _isPublic,
                onChanged: (v) => setState(() => _isPublic = v),
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (_nameCtrl.text.trim().isEmpty) return;
                await FirestoreService.addVaccination(Vaccination(
                  id: '',
                  petId: pet.id,
                  name: _nameCtrl.text.trim(),
                  dateAdministered: DateTime.now(),
                  nextDueDate: DateTime.now().add(Duration(days: 365)), // 1 year default
                  isPublic: _isPublic,
                ));
                Navigator.pop(ctx);
              },
              child: Text('Add'),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pet.name)),
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
              onPressed: () => _addVaccination(context),
              icon: Icon(Icons.medical_services),
              label: Text('Add Medical Record'),
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (pet.avatarUrl != null)
              Image.network(pet.avatarUrl!, height: 200, width: double.infinity, fit: BoxFit.cover)
            else
              Container(height: 200, color: Colors.grey[300], child: Center(child: Icon(Icons.pets, size: 80))),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(pet.species, style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                  SizedBox(height: 8),
                  Text(pet.about, style: TextStyle(fontSize: 16)),
                  Divider(height: 32),
                  Text('Vaccination Card', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  StreamBuilder<List<Vaccination>>(
                    stream: FirestoreService.streamPetVaccinations(pet.id, onlyPublic: !isOwner),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      final vacs = snapshot.data!;
                      if (vacs.isEmpty) return Text('No vaccination records available.');
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: vacs.length,
                        itemBuilder: (context, i) {
                          final v = vacs[i];
                          return Card(
                            child: ListTile(
                              leading: Icon(Icons.vaccines, color: Colors.teal),
                              title: Text(v.name),
                              subtitle: Text('Given: ${v.dateAdministered.toString().split(' ')[0]}'),
                              trailing: Icon(v.isPublic ? Icons.visibility : Icons.visibility_off, size: 16),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
