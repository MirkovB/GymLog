import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistika'),
        backgroundColor: const Color(0xFF808080),
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pregled',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.fitness_center,
                    value: '24',
                    label: 'Treninga',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.calendar_today,
                    value: '8',
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
                    icon: Icons.trending_down,
                    value: '2.5 kg',
                    label: 'Izgubljeno',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.timer,
                    value: '45 min',
                    label: 'Prosek',
                    color: Colors.purple,
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
            _ExerciseStatItem(exercise: 'Bench Press', count: 18),
            _ExerciseStatItem(exercise: 'Squats', count: 16),
            _ExerciseStatItem(exercise: 'Deadlift', count: 14),
            _ExerciseStatItem(exercise: 'Pull-ups', count: 12),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Grafici uskoro',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseStatItem extends StatelessWidget {
  final String exercise;
  final int count;

  const _ExerciseStatItem({
    required this.exercise,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF808080),
          child: const Icon(Icons.fitness_center, color: Colors.white, size: 20),
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
