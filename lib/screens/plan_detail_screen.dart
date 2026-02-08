import 'package:flutter/material.dart';
import '../models/plan.dart';
import '../models/exercise.dart';
import '../services/firebase_service.dart';

class PlanDetailScreen extends StatefulWidget {
  final Plan plan;
  final String userId;

  const PlanDetailScreen({
    super.key,
    required this.plan,
    required this.userId,
  });

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Map<String, PlanDay> _days;
  late Map<String, TextEditingController> _dayTitleControllers;
  late Future<List<Exercise>> _exercisesFuture;
  bool _isSaving = false;

  final List<String> _weekDays = [
    'Ponedeljak',
    'Utorak',
    'Sreda',
    'Četvrtak',
    'Petak',
    'Subota',
    'Nedelja'
  ];

  final List<String> _weekDaysKeys = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];

  @override
  void initState() {
    super.initState();
    _days = Map.from(widget.plan.days);
    _exercisesFuture = _firebaseService.getExercises(widget.userId);
    _dayTitleControllers = {};

    // Inicijalizuj kontrolere za sve dane
    for (int i = 0; i < _weekDaysKeys.length; i++) {
      final dayKey = _weekDaysKeys[i];
      _dayTitleControllers[dayKey] = TextEditingController(
        text: _days[dayKey]?.name ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _dayTitleControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showAddExerciseDialog(String dayKey, String dayLabel) {
    // Ako dan ne postoji, kreiraj ga
    if (!_days.containsKey(dayKey)) {
      setState(() {
        _days[dayKey] = PlanDay(name: '', exerciseIds: []);
      });
    }

    showDialog(
      context: context,
      builder: (context) => FutureBuilder<List<Exercise>>(
        future: _exercisesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return AlertDialog(
              title: const Text('Greška'),
              content: Text('Greška: ${snapshot.error}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          }

          final exercises = snapshot.data ?? [];
          final currentDay = _days[dayKey];
          final availableExercises = exercises
              .where((e) => !currentDay!.exerciseIds.contains(e.id))
              .toList();

          return AlertDialog(
            title: Text('Dodaj vežbu u $dayLabel'),
            content: SizedBox(
              width: double.maxFinite,
              child: availableExercises.isEmpty
                  ? const Center(
                      child: Text('Sve vežbe su već dodane ili nema vežbi'),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: availableExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = availableExercises[index];
                        return ListTile(
                          title: Text(exercise.name),
                          subtitle: exercise.personalRecord != null
                              ? Text('Rekord: ${exercise.personalRecord} kg')
                              : const Text('Nema rekorda'),
                          onTap: () {
                            setState(() {
                              _days[dayKey]!.exerciseIds.add(exercise.id);
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Otkaži'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _removeExerciseFromDay(
      String dayKey, String dayLabel, String exerciseId, String exerciseName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ukloni vežbu'),
        content: Text('Ukloniti $exerciseName iz $dayLabel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ne'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              if (_days.containsKey(dayKey)) {
                setState(() {
                  _days[dayKey]!.exerciseIds.remove(exerciseId);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Ukloni'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAllDays() async {
    setState(() {
      _isSaving = true;
    });

    try {
      for (var dayKey in _weekDaysKeys) {
        final dayTitle = _dayTitleControllers[dayKey]!.text;
        
        if (dayTitle.isNotEmpty || (_days[dayKey]?.exerciseIds.isNotEmpty ?? false)) {
          final exerciseIds = _days[dayKey]?.exerciseIds ?? [];

          await _firebaseService.setPlanDay(
            widget.userId,
            widget.plan.id,
            dayKey,
            dayTitle,
            exerciseIds,
          );
        }
      }

      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan uspešno sačuvan!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška pri čuvanju: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan.title),
        backgroundColor: const Color(0xFF808080),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: _saveAllDays,
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text('Sačuvaj'),
                    ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _weekDays.length,
        itemBuilder: (context, index) {
          final dayLabel = _weekDays[index];
          final dayKey = _weekDaysKeys[index];
          final dayExercises =
              _days[dayKey]?.exerciseIds ?? <String>[];

          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              
                  TextField(
                    controller: _dayTitleControllers[dayKey],
                    decoration: InputDecoration(
                      hintText: 'Npr. Push, Pull, Odmor...',
                      labelText: dayLabel,
                      labelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.label),
                    ),
                  ),
                  const SizedBox(height: 12),

   
                  if (dayExercises.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Nema dodanih vežbi',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        children: List.generate(
                          dayExercises.length,
                          (exIndex) => FutureBuilder<List<Exercise>>(
                            future: _exercisesFuture,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox.shrink();
                              }

                              final exercises = snapshot.data!;
                              final exerciseId = dayExercises[exIndex];
                              final exercise = exercises.firstWhere(
                                (e) => e.id == exerciseId,
                                orElse: () => Exercise(
                                  id: exerciseId,
                                  name: 'Nepoznata vežba',
                                ),
                              );

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF808080),
                                    radius: 20,
                                    child: const Icon(
                                      Icons.fitness_center,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  title: Text(
                                    exercise.name,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red, size: 20),
                                    onPressed: () {
                                      _removeExerciseFromDay(
                                        dayKey,
                                        dayLabel,
                                        exerciseId,
                                        exercise.name,
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

              
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF808080),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () =>
                          _showAddExerciseDialog(dayKey, dayLabel),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Dodaj vežbu'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
