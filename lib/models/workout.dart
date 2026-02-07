class WorkoutSet {
  final int reps;
  final double weight;

  WorkoutSet({
    required this.reps,
    required this.weight,
  });

  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      reps: map['reps'] as int,
      weight: (map['weight'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reps': reps,
      'weight': weight,
    };
  }
}

class WorkoutExercise {
  final String exerciseId;
  final List<WorkoutSet> sets;

  WorkoutExercise({
    required this.exerciseId,
    required this.sets,
  });

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    final setsList = (map['sets'] as List? ?? [])
        .map((set) => WorkoutSet.fromMap(set as Map<String, dynamic>))
        .toList();

    return WorkoutExercise(
      exerciseId: map['exerciseId'] as String,
      sets: setsList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'sets': sets.map((set) => set.toMap()).toList(),
    };
  }
}

class Workout {
  final String id;
  final String userId;
  final String planId;
  final String dayName;
  final DateTime date;
  final Map<String, WorkoutExercise> exercises;

  Workout({
    required this.id,
    required this.userId,
    required this.planId,
    required this.dayName,
    required this.date,
    required this.exercises,
  });

  factory Workout.fromMap(Map<String, dynamic> map, String id) {
    final exercisesData = map['exercises'] as Map<String, dynamic>? ?? {};
    final exercises = <String, WorkoutExercise>{};

    exercisesData.forEach((key, value) {
      exercises[key] = WorkoutExercise.fromMap(value as Map<String, dynamic>);
    });

    return Workout(
      id: id,
      userId: map['userId'] as String,
      planId: map['planId'] as String,
      dayName: map['dayName'] as String,
      date: DateTime.parse(map['date'] as String),
      exercises: exercises,
    );
  }

  Map<String, dynamic> toMap() {
    final exercisesMap = <String, dynamic>{};
    exercises.forEach((key, value) {
      exercisesMap[key] = value.toMap();
    });

    return {
      'userId': userId,
      'planId': planId,
      'dayName': dayName,
      'date': date.toIso8601String(),
      'exercises': exercisesMap,
    };
  }
}
