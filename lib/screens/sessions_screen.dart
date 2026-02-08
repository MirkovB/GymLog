import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../models/workout.dart';
import '../services/firebase_service.dart';
import 'start_workout_screen.dart';
import 'workout_detail_screen.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final String _userId = 'test-user-1';
  late Future<List<Workout>> _workoutsFuture;

  @override
  void initState() {
    super.initState();
    _workoutsFuture = _firebaseService.getWorkouts(_userId);
  }

  void _refreshWorkouts() {
    setState(() {
      _workoutsFuture = _firebaseService.getWorkouts(_userId);
    });
  }

  String _formatDuration(Workout workout) {
    if (workout.durationSeconds != null) {
      final seconds = workout.durationSeconds!;
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      final secs = seconds % 60;
      if (hours > 0) {
        return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
      }
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }

    int totalSets = 0;
    for (var exercise in workout.exercises.values) {
      totalSets += exercise.sets.length;
    }
    int estimatedMinutes = (workout.exercises.length * 3) + totalSets;
    return '~${estimatedMinutes} min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treninzi'),
        backgroundColor: const Color(0xFF808080),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Workout>>(
        future: _workoutsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Greška: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF808080),
                    ),
                    onPressed: _refreshWorkouts,
                    child: const Text('Pokušaj ponovo'),
                  ),
                ],
              ),
            );
          }

          final workouts = snapshot.data ?? [];

          if (workouts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fitness_center,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Nema treninga. Započni novi!'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index];
              final exerciseCount = workout.exercises.length;
                final duration = _formatDuration(workout);

              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF808080),
                    child: const Icon(Icons.fitness_center,
                        color: Colors.white),
                  ),
                  title: Text(workout.dayName),
                  subtitle: Text(
                    '${workout.date.day}.${workout.date.month}.${workout.date.year} • $exerciseCount vežbi • $duration',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutDetailScreen(
                          workout: workout,
                          userId: _userId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StartWorkoutScreen(userId: _userId),
            ),
          ).then((_) => _refreshWorkouts());
        },
        backgroundColor: const Color(0xFF808080),
        icon: Icon(
          StartWorkoutScreen.hasDraft()
              ? Icons.play_circle_fill
              : Icons.play_arrow,
        ),
        label: Text(
          StartWorkoutScreen.hasDraft()
              ? 'Nastavi trening'
              : 'Započni trening',
        ),
      ),
    );
  }
}
