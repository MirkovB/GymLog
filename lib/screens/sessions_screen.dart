import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../models/workout.dart';
import '../services/firebase_service.dart';
import '../providers/user_provider.dart';
import 'start_workout_screen.dart';
import 'workout_detail_screen.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<Workout>> _workoutsFuture;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.id ?? 'demo-user';
    _workoutsFuture = _firebaseService.getWorkouts(userId);
  }

  void _refreshWorkouts() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.id ?? 'demo-user';
    setState(() {
      _workoutsFuture = _firebaseService.getWorkouts(userId);
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
    final userProvider = Provider.of<UserProvider>(context);
    final isGuest = userProvider.user == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isGuest ? 'Treninzi (Pregled)' : 'Treninzi'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          if (isGuest)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange[100],
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Prijavite se da biste kreirali i pratili treninge',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: FutureBuilder<List<Workout>>(
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
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Colors.white,
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
                        const Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: Colors.grey,
                        ),
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
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          child: const Icon(
                            Icons.fitness_center,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(workout.dayName),
                        subtitle: Text(
                          '${workout.date.day}.${workout.date.month}.${workout.date.year} • $exerciseCount vežbi • $duration',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          final userProvider = Provider.of<UserProvider>(
                            context,
                            listen: false,
                          );
                          final userId = userProvider.user?.id ?? '';
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkoutDetailScreen(
                                workout: workout,
                                userId: userId,
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
          ),
        ],
      ),
      floatingActionButton: isGuest
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                final userProvider = Provider.of<UserProvider>(
                  context,
                  listen: false,
                );
                final userId = userProvider.user?.id ?? '';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StartWorkoutScreen(userId: userId),
                  ),
                ).then((_) => _refreshWorkouts());
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
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
