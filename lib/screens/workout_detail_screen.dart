import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../services/firebase_service.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;
  final String userId;

  const WorkoutDetailScreen({
    required this.workout,
    required this.userId,
    super.key,
  });

  String _formatDuration(int? seconds) {
    if (seconds == null) {
      return '-';
    }
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day.$month.$year';
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalji treninga'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: FutureBuilder<List<Exercise>>(
        future: firebaseService.getExercises(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Greska: ${snapshot.error}'),
            );
          }

          final exercises = snapshot.data ?? [];
          final exerciseMap = {
            for (var exercise in exercises) exercise.id: exercise.name
          };

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                child: ListTile(
                  title: Text(workout.dayName),
                  subtitle: Text(
                    '${_formatDate(workout.date)} • ${_formatDuration(workout.durationSeconds)}',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              for (var entry in workout.exercises.entries)
                Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exerciseMap[entry.key] ?? 'Nepoznata vezba',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (var i = 0; i < entry.value.sets.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Text(
                              'Set ${i + 1}: ${entry.value.sets[i].reps} x ${entry.value.sets[i].weight} kg',
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

