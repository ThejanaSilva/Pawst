import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/pet.dart';
import '../models/appointment.dart';
import '../models/health_record.dart';

class PetProfileScreen extends StatefulWidget {
  const PetProfileScreen({super.key});

<<<<<<< HEAD
  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}
=======
  const PetProfileScreen({super.key, required this.pet, this.isOwner = true});
>>>>>>> origin/dev_wta_v2

class _PetProfileScreenState extends State<PetProfileScreen> {
  bool isEditing = false;
  bool isLoading = true;

  Pet? pet;

  late TextEditingController nameController;
  late TextEditingController breedController;
  late TextEditingController bioController;
  late TextEditingController ageController;
  late TextEditingController weightController;

  String selectedGender = "Male";

  bool goodWithDogs = true;
  bool goodWithCats = true;
  bool goodWithChildren = true;

  double friendlinessLevel = 5;

  final List<Map<String, String>> posts = [
    {
      "image": "https://picsum.photos/id/1025/600/600",
      "caption": "Beach day 🐾",
    },
    {
      "image": "https://picsum.photos/id/1074/600/600",
      "caption": "Vet visit today 🏥",
    },
    {
      "image": "https://picsum.photos/id/237/600/600",
      "caption": "Playing fetch 🎾",
    },
  ];

  @override
  void initState() {
    super.initState();
    loadPet();
  }

  Future<void> loadPet() async {
    const String petId = "pet_001";
    try {
      // Fetch pet document from Firestore
      final doc =
          await FirebaseFirestore.instance.collection('pets').doc(petId).get();

      // Assuming Pet has a fromDocument factory constructor
      // Convert Firestore document to Pet model using fromMap
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        pet = Pet.fromMap(data);
      } else {
        debugPrint('Pet document data is null');
        pet = null;
      }

      // Initialise controllers with pet data
      nameController = TextEditingController(text: pet!.name);
      breedController = TextEditingController(text: pet!.breed);
      bioController = TextEditingController(text: pet!.bio);
      ageController = TextEditingController(text: pet!.ageYears.toString());
      weightController = TextEditingController(text: pet!.weightKg.toString());

      // Initialise other fields
      selectedGender = pet!.gender;
      goodWithDogs = pet!.goodWithDogs;
      goodWithCats = pet!.goodWithCats;
      goodWithChildren = pet!.goodWithChildren;
      friendlinessLevel = pet!.friendlinessLevel.toDouble();
    } catch (e) {
      debugPrint("Error loading pet: $e");
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String getFriendlinessText(int level) {
    switch (level) {
      case 1:
        return "Aggressive 😡";
      case 2:
        return "Cautious 😐";
      case 3:
        return "Neutral 🙂";
      case 4:
        return "Friendly 😊";
      case 5:
        return "Very Friendly 🥰";
      default:
        return "Unknown";
    }
  }

  void _saveProfile() {
    if (pet == null) return;

    final updated = pet!.copyWith(
      name: nameController.text,
      breed: breedController.text,
      gender: selectedGender,
      bio: bioController.text,
      ageYears: int.tryParse(ageController.text) ?? pet!.ageYears,
      weightKg: double.tryParse(weightController.text) ?? pet!.weightKg,
      friendlinessLevel: friendlinessLevel.round(),
      goodWithDogs: goodWithDogs,
      goodWithCats: goodWithCats,
      goodWithChildren: goodWithChildren,
    );

    setState(() {
      pet = updated;
      isEditing = false;
    });

    FirebaseFirestore.instance
        .collection("pets")
        .doc(pet!.id)
        .update(updated.toMap());
  }

  void _addPost() {
    final captionController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "New Post",
        ),
        content: TextField(
          controller: captionController,
          decoration: const InputDecoration(
            labelText: "Caption",
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                posts.add(
                  {
                    "image": "https://picsum.photos/600?random=${posts.length}",
                    "caption": captionController.text,
                  },
                );
              });

              Navigator.pop(context);
            },
            child: const Text(
              "Add",
            ),
          ),
        ],
      ),
    );
  }

  void _showPostDialog(
    Map<String, String> post,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          post["caption"] ?? "",
        ),
        content: Image.network(
          post["image"]!,
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                posts.remove(post);
              });

              Navigator.pop(context);
            },
            child: const Text(
              "Delete",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Close",
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfileTab() {
    if (isLoading || pet == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(
              pet!.imageUrl,
            ),
          ),
          const SizedBox(height: 20),
          isEditing
              ? TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Pet Name",
                  ),
                )
              : Text(
                  pet!.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          const SizedBox(height: 8),
          isEditing
              ? TextField(
                  controller: breedController,
                  decoration: const InputDecoration(
                    labelText: "Breed",
                  ),
                )
              : Text(
                  pet!.breed,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "About",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  isEditing
                      ? DropdownButtonFormField<String>(
                          initialValue: selectedGender,
                          decoration: const InputDecoration(
                            labelText: "Gender",
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: "Male",
                              child: Text("Male"),
                            ),
                            DropdownMenuItem(
                              value: "Female",
                              child: Text("Female"),
                            ),
                          ],
                          onChanged: (v) {
                            setState(() {
                              selectedGender = v!;
                            });
                          },
                        )
                      : _infoRow(
                          "Gender",
                          pet!.gender,
                        ),
                  isEditing
                      ? TextField(
                          controller: ageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Age",
                          ),
                        )
                      : _infoRow(
                          "Age",
                          "${pet!.ageYears} Years",
                        ),
                  isEditing
                      ? TextField(
                          controller: weightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Weight",
                          ),
                        )
                      : _infoRow(
                          "Weight",
                          "${pet!.weightKg} kg",
                        ),
                  const SizedBox(height: 12),
                  isEditing
                      ? TextField(
                          controller: bioController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: "Bio",
                          ),
                        )
                      : _infoRow(
                          "Bio",
                          pet!.bio,
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Friendliness",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: friendlinessLevel,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: isEditing
                        ? (value) {
                            setState(() {
                              friendlinessLevel = value;
                            });
                          }
                        : null,
                  ),
                  Text(
                    getFriendlinessText(
                      friendlinessLevel.round(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: goodWithDogs,
                  title: const Text(
                    "Good with Dogs",
                  ),
                  onChanged: isEditing
                      ? (value) {
                          setState(() {
                            goodWithDogs = value;
                          });
                        }
                      : null,
                ),
                SwitchListTile(
                  value: goodWithCats,
                  title: const Text(
                    "Good with Cats",
                  ),
                  onChanged: isEditing
                      ? (value) {
                          setState(() {
                            goodWithCats = value;
                          });
                        }
                      : null,
                ),
                SwitchListTile(
                  value: goodWithChildren,
                  title: const Text(
                    "Good with Children",
                  ),
                  onChanged: isEditing
                      ? (value) {
                          setState(() {
                            goodWithChildren = value;
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget buildFeedTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: posts.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemBuilder: (_, index) {
        if (index == 0) {
          return InkWell(
            onTap: _addPost,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.add,
                  size: 40,
                ),
              ),
            ),
          );
        }

        final post = posts[index - 1];

        return GestureDetector(
          onTap: () => _showPostDialog(post),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              post["image"]!,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  Widget buildHealthTab() {
    if (isLoading || pet == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// NEXT CLINIC VISIT
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.alarm),
                      SizedBox(width: 8),
                      Text(
                        "Next Clinic Visit",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (pet!.appointments.isNotEmpty)
                    Column(
                      children: [
                        Text(
                          pet!.appointments.first.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(pet!.appointments.first.clinic),
                        Text(
                          "${pet!.appointments.first.date.day}/${pet!.appointments.first.date.month}/${pet!.appointments.first.date.year}",
                        ),
                      ],
                    )
                  else
                    const Text("No upcoming visits"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// CLINIC APPOINTMENTS
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Clinic Appointments",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showAddAppointmentDialog,
                        icon: const Icon(Icons.add),
                        label: const Text("Add"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...pet!.appointments.asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final appointment = entry.value;

                      return ListTile(
                        leading: const Icon(Icons.local_hospital),
                        title: Text(appointment.title),
                        subtitle: Text(appointment.clinic),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              pet!.appointments.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// HEALTH RECORDS
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Health Records",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showAddHealthDialog,
                        icon: const Icon(Icons.add),
                        label: const Text("Add"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...pet!.healthRecords.asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final record = entry.value;

                      return ListTile(
                        leading: const Icon(Icons.monitor_heart),
                        title: Text(record.title),
                        subtitle: Text(record.value),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              pet!.healthRecords.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAppointmentDialog() {
    final titleController = TextEditingController();
    final clinicController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Clinic Visit"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Visit Title"),
            ),
            TextField(
              controller: clinicController,
              decoration: const InputDecoration(labelText: "Clinic Name"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                pet!.appointments.add(
                  Appointment(
                    title: titleController.text,
                    clinic: clinicController.text,
                    notes: "",
                    date: DateTime.now(),
                  ),
                );
              });

              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showAddHealthDialog() {
    final titleController = TextEditingController();
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Health Record"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Record Name"),
            ),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(labelText: "Value"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                pet!.healthRecords.add(
                  HealthRecord(
                    title: titleController.text,
                    value: valueController.text,
                    date: DateTime.now(),
                  ),
                );
              });

              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || pet == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(pet!.name),
          actions: [
            IconButton(
              icon: Icon(isEditing ? Icons.check : Icons.edit),
              onPressed: () {
                if (isEditing) {
                  _saveProfile();
                } else {
                  setState(() => isEditing = true);
                }
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: "Profile"),
              Tab(text: "Feed"),
              Tab(text: "Health"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildProfileTab(),
            buildFeedTab(),
            buildHealthTab(),
          ],
        ),
      ),
    );
  }
}
