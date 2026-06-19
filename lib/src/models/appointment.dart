class Appointment {
  final String title;
  final DateTime date;
  final String clinic;
  final String notes;

  Appointment({
    required this.title,
    required this.date,
    required this.clinic,
    required this.notes,
  });

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      title: map['title'] ?? '',
      date: DateTime.parse(map['date']),
      clinic: map['clinic'] ?? '',
      notes: map['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date.toIso8601String(),
      'clinic': clinic,
      'notes': notes,
    };
  }
}
