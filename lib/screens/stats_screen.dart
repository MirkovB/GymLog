import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/body_metric.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../services/firebase_service.dart';
import '../providers/user_provider.dart';
import '../widgets/app_drawer.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<_StatsData> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  Future<_StatsData> _loadStats() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.id ?? 'demo-user';
    final workouts = await _firebaseService.getWorkouts(userId);
    final metrics = await _firebaseService.getBodyMetrics(userId);
    final exercises = await _firebaseService.getExercises(userId);

    final totalWorkouts = workouts.length;
    final totalWeeks = _calculateWeeks(workouts);
    final avgWorkoutMinutes = _calculateAvgMinutes(workouts);
    final weightDelta = _calculateWeightDelta(metrics);

    final exerciseStats = _buildExerciseStats(workouts, exercises);

    return _StatsData(
      totalWorkouts: totalWorkouts,
      totalWeeks: totalWeeks,
      avgWorkoutMinutes: avgWorkoutMinutes,
      weightDelta: weightDelta,
      metrics: metrics,
      exerciseStats: exerciseStats,
    );
  }

  int _calculateWeeks(List<Workout> workouts) {
    if (workouts.isEmpty) return 0;
    DateTime minDate = workouts.first.date;
    DateTime maxDate = workouts.first.date;
    for (final workout in workouts) {
      if (workout.date.isBefore(minDate)) minDate = workout.date;
      if (workout.date.isAfter(maxDate)) maxDate = workout.date;
    }
    final diffDays = maxDate.difference(minDate).inDays;
    return (diffDays / 7).ceil() + 1;
  }

  int? _calculateAvgMinutes(List<Workout> workouts) {
    if (workouts.isEmpty) return null;
    int totalMinutes = 0;
    for (final workout in workouts) {
      if (workout.durationSeconds != null) {
        totalMinutes += (workout.durationSeconds! / 60).round();
      } else {
        totalMinutes += _estimateMinutes(workout);
      }
    }
    return (totalMinutes / workouts.length).round();
  }

  int _estimateMinutes(Workout workout) {
    int totalSets = 0;
    for (final exercise in workout.exercises.values) {
      totalSets += exercise.sets.length;
    }
    return (workout.exercises.length * 3) + totalSets;
  }

  double _calculateWeightDelta(List<BodyMetric> metrics) {
    if (metrics.length < 2) return 0;
    final sorted = [...metrics]..sort((a, b) => a.date.compareTo(b.date));
    return sorted.last.weight - sorted.first.weight;
  }

  List<_ExerciseStat> _buildExerciseStats(
    List<Workout> workouts,
    List<Exercise> exercises,
  ) {
    final nameById = {for (final e in exercises) e.id: e.name};
    final counts = <String, int>{};
    for (final workout in workouts) {
      for (final exerciseId in workout.exercises.keys) {
        counts[exerciseId] = (counts[exerciseId] ?? 0) + 1;
      }
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries
        .take(4)
        .map(
          (entry) => _ExerciseStat(
            name: nameById[entry.key] ?? 'Nepoznata vežba',
            count: entry.value,
          ),
        )
        .toList();
  }

  void _refreshStats() {
    setState(() {
      _statsFuture = _loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistika'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<_StatsData>(
        future: _statsFuture,
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
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _refreshStats,
                    child: const Text('Pokušaj ponovo'),
                  ),
                ],
              ),
            );
          }

          final stats = snapshot.data;
          if (stats == null) {
            return const Center(child: Text('Nema podataka.'));
          }

          final weightDeltaText = stats.metrics.length >= 2
              ? '${stats.weightDelta >= 0 ? '+' : ''}${stats.weightDelta.toStringAsFixed(1)} kg'
              : '--';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pregled', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.fitness_center,
                        value: '${stats.totalWorkouts}',
                        label: 'Treninga',
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.calendar_today,
                        value: '${stats.totalWeeks}',
                        label: 'Nedelja',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.trending_up,
                        value: weightDeltaText,
                        label: 'Promena',
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.timer,
                        value: stats.avgWorkoutMinutes == null
                            ? '--'
                            : '${stats.avgWorkoutMinutes} min',
                        label: 'Prosek',
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Najčešće vežbe',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (stats.exerciseStats.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.fitness_center, color: Colors.grey[400]),
                          const SizedBox(width: 12),
                          const Text('Nema statistike vežbi.'),
                        ],
                      ),
                    ),
                  )
                else
                  for (final item in stats.exerciseStats)
                    _ExerciseStatItem(exercise: item.name, count: item.count),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatsData {
  final int totalWorkouts;
  final int totalWeeks;
  final int? avgWorkoutMinutes;
  final double weightDelta;
  final List<BodyMetric> metrics;
  final List<_ExerciseStat> exerciseStats;

  _StatsData({
    required this.totalWorkouts,
    required this.totalWeeks,
    required this.avgWorkoutMinutes,
    required this.weightDelta,
    required this.metrics,
    required this.exerciseStats,
  });
}

class _ExerciseStat {
  final String name;
  final int count;

  _ExerciseStat({required this.name, required this.count});
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ExerciseStatItem extends StatelessWidget {
  final String exercise;
  final int count;

  const _ExerciseStatItem({required this.exercise, required this.count});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          child: const Icon(
            Icons.fitness_center,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(exercise),
        trailing: Chip(
          label: Text('$count×'),
          backgroundColor: Colors.grey[200],
        ),
      ),
    );
  }
}
