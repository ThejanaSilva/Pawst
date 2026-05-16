class Pet {
  final String id;
  final String ownerId;
  final String name;
  final String species;
  final String about;
  final String? avatarUrl;

  Pet({required this.id, required this.ownerId, required this.name, required this.species, required this.about, this.avatarUrl});

  Map<String, dynamic> toMap() => {
        'id': id,
        'ownerId': ownerId,
        'name': name,
        'species': species,
        'about': about,
        'avatarUrl': avatarUrl,
      };

  static Pet fromMap(Map<String, dynamic> m) => Pet(
        id: m['id'] ?? '',
        ownerId: m['ownerId'] ?? '',
        name: m['name'] ?? '',
        species: m['species'] ?? '',
        about: m['about'] ?? '',
        avatarUrl: m['avatarUrl'],
      );
}
