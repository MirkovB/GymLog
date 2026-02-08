import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../models/exercise.dart';
import '../services/firebase_service.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final String _userId = 'test-user-1'; 
  late Future<List<Exercise>> _exercisesFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _exercisesFuture = _firebaseService.getExercises(_userId);
  }

  void _refreshExercises() {
    setState(() {
      _exercisesFuture = _firebaseService.getExercises(_userId);
    });
  }

  void _showAddExerciseDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dodaj novu vežbu'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Naziv vežbe',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF808080),
            ),
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                try {
                  await _firebaseService.addExercise(_userId, controller.text);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _refreshExercises();
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Greška: $e')),
                  );
                }
              }
            },
            child: const Text('Dodaj'),
          ),
        ],
      ),
    );
  }

  void _deleteExercise(String exerciseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Obriši vežbu'),
        content: const Text('Da li si siguran da želiš da obrišeš ovu vežbu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ne'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              try {
                await _firebaseService.deleteExercise(_userId, exerciseId);
                if (!context.mounted) return;
                Navigator.pop(context);
                _refreshExercises();
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Greška: $e')),
                );
              }
            },
            child: const Text('Obriši'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vežbe'),
        backgroundColor: const Color(0xFF808080),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _ExerciseSearchDelegate(_exercisesFuture),
              );
            },
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
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Exercise>>(
              future: _exercisesFuture,
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
                          onPressed: _refreshExercises,
                          child: const Text('Pokušaj ponovo'),
                        ),
                      ],
                    ),
                  );
                }

                final exercises = snapshot.data ?? [];
                final filteredExercises = exercises
                    .where((exercise) =>
                        exercise.name.toLowerCase().contains(_searchQuery))
                    .toList();

                if (filteredExercises.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.fitness_center,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(_searchQuery.isEmpty
                            ? 'Nema vežbi. Dodaj novu!'
                            : 'Nema rezultata pretrage'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = filteredExercises[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF808080),
                          child: const Icon(Icons.fitness_center,
                              color: Colors.white, size: 20),
                        ),
                        title: Text(exercise.name),
                        subtitle: Text(
                          'Rekord: ${exercise.personalRecord ?? '-'} kg • Treninga: ${exercise.workoutCount} • Poslednji put: ${_formatLastDone(exercise.lastDone)}',
                        ),
                        trailing: PopupMenuButton(
                          onSelected: (value) {
                            if (value == 'delete') {
                              _deleteExercise(exercise.id);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Obriši'),
                            ),
                          ],
                        ),
                        onTap: () {
                       
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExerciseDialog,
        backgroundColor: const Color(0xFF808080),
        child: const Icon(Icons.add),
      ),
    );
  }
}

String _formatLastDone(DateTime? date) {
  if (date == null) {
    return 'Nikad';
  }
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  return '$day.$month.$year';
}

class _ExerciseSearchDelegate extends SearchDelegate<String> {
  final Future<List<Exercise>> exercisesFuture;

  _ExerciseSearchDelegate(this.exercisesFuture);

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          close(context, '');
        },
      );

  @override
  Widget buildResults(BuildContext context) =>
      _buildSearchResults(context, query);

  @override
  Widget buildSuggestions(BuildContext context) =>
      _buildSearchResults(context, query);

  Widget _buildSearchResults(BuildContext context, String query) {
    return FutureBuilder<List<Exercise>>(
      future: exercisesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Greška: ${snapshot.error}'));
        }

        final exercises = snapshot.data ?? [];
        final filtered = exercises
            .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final exercise = filtered[index];
            return ListTile(
              title: Text(exercise.name),
              subtitle: Text(
                'Rekord: ${exercise.personalRecord ?? '-'} kg • Treninga: ${exercise.workoutCount} • Poslednji put: ${_formatLastDone(exercise.lastDone)}',
              ),
              onTap: () {
                close(context, exercise.name);
              },
            );
          },
        );
      },
    );
  }
}

