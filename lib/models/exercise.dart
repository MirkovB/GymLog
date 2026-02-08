class Exercise {
  final String id;
  final String name;
  final DateTime? lastDone;
  final double? personalRecord;
  final int workoutCount;

  Exercise({
    required this.id,
    required this.name,
    this.lastDone,
    this.personalRecord,
    this.workoutCount = 0,
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
      workoutCount: map['workoutCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lastDone': lastDone?.toIso8601String(),
      'personalRecord': personalRecord,
      'workoutCount': workoutCount,
    };
  }
}
