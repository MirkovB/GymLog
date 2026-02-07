class PlanDay {
  final String name;
  final List<String> exerciseIds;

  PlanDay({
    required this.name,
    required this.exerciseIds,
  });

  factory PlanDay.fromMap(Map<String, dynamic> map) {
    return PlanDay(
      name: map['name'] as String,
      exerciseIds: List<String>.from(map['exerciseIds'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'exerciseIds': exerciseIds,
    };
  }
}

class Plan {
  final String id;
  final String title;
  final Map<String, PlanDay> days;
  final bool isActive;
  final DateTime createdAt;

  Plan({
    required this.id,
    required this.title,
    required this.days,
    this.isActive = false,
    required this.createdAt,
  });

  factory Plan.fromMap(Map<String, dynamic> map, String id) {
    final daysData = map['days'] as Map<String, dynamic>? ?? {};
    final days = <String, PlanDay>{};

    daysData.forEach((key, value) {
      days[key] = PlanDay.fromMap(value as Map<String, dynamic>);
    });

    return Plan(
      id: id,
      title: map['title'] as String,
      days: days,
      isActive: map['isActive'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    final daysMap = <String, dynamic>{};
    days.forEach((key, value) {
      daysMap[key] = value.toMap();
    });

    return {
      'title': title,
      'days': daysMap,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
