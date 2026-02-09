class BodyMetric {
  final String id;
  final double weight;
  final DateTime date;

  BodyMetric({required this.id, required this.weight, required this.date});

  factory BodyMetric.fromMap(Map<String, dynamic> map, String id) {
    return BodyMetric(
      id: id,
      weight: (map['weight'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {'weight': weight, 'date': date.toIso8601String()};
  }
}
