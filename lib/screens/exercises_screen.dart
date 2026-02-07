import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exercises = [
      'Bench Press',
      'Squats',
      'Deadlift',
      'Pull-ups',
      'Shoulder Press',
      'Barbell Row',
      'Lunges',
      'Bicep Curls',
      'Tricep Extensions',
      'Leg Press',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vežbe'),
        backgroundColor: const Color(0xFF808080),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pretraži vežbe...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF808080),
                      child: const Icon(Icons.fitness_center, color: Colors.white, size: 20),
                    ),
                    title: Text(exercises[index]),
                    subtitle: Text('Kategorija ${(index % 3) + 1}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF808080),
        child: const Icon(Icons.add),
      ),
    );
  }
}
