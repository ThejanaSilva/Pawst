class Vaccination {
  final String id;
  final String name;
  final DateTime date;
  final bool completed;

  Vaccination({
    required this.id,
    required this.name,
    required this.date,
    required this.completed,
  });

  factory Vaccination.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    return Vaccination(
      id: id,
      name: map['name'] ?? '',
      date: DateTime.parse(
        map['date'] ?? DateTime.now().toIso8601String(),
      ),
      completed: map['completed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'completed': completed,
    };
  }
}
