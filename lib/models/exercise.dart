class Exercise {
  final String id;
  final String name;
  final DateTime? lastDone;
  final double? personalRecord;

  Exercise({
    required this.id,
    required this.name,
    this.lastDone,
    this.personalRecord,
  });

  factory Exercise.fromMap(Map<String, dynamic> map, String id) {
    return Exercise(
      id: id,
      name: map['name'] as String,
      lastDone: map['lastDone'] != null
          ? DateTime.parse(map['lastDone'] as String)
          : null,
      personalRecord: map['personalRecord'] != null
          ? (map['personalRecord'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lastDone': lastDone?.toIso8601String(),
      'personalRecord': personalRecord,
    };
  }
}
