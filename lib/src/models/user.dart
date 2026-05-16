class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String role; // 'owner' | 'veterinarian'

  AppUser({required this.id, required this.email, required this.displayName, this.role = 'owner'});

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'role': role,
      };

  static AppUser fromMap(Map<String, dynamic> m) => AppUser(
        id: m['id'] ?? '',
        email: m['email'] ?? '',
        displayName: m['displayName'] ?? '',
        role: m['role'] ?? 'owner',
      );
}
