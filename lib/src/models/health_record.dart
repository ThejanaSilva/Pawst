class HealthRecord {
  final String title;
  final String value;
  final DateTime date;

  HealthRecord({
    required this.title,
    required this.value,
    required this.date,
  });

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      title: map['title'] ?? '',
      value: map['value'] ?? '',
      date: DateTime.parse(map['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'value': value,
      'date': date.toIso8601String(),
    };
  }
}
