import 'package:flutter/material.dart';
import 'dart:async';
import '../models/exercise.dart';
import '../models/plan.dart';
import '../models/workout.dart';
import '../services/firebase_service.dart';

class StartWorkoutScreen extends StatefulWidget {
  final String userId;

  const StartWorkoutScreen({required this.userId, super.key});

  static bool hasDraft() {
    return _StartWorkoutScreenState.hasDraft;
  }

  @override
  State<StartWorkoutScreen> createState() => _StartWorkoutScreenState();
}

class _StartWorkoutScreenState extends State<StartWorkoutScreen> {
  static DateTime? _draftStartAt;
  static String? _draftDayKey;
  static String? _draftDayName;
  static Map<String, List<WorkoutSet>> _draftWorkoutData = {};

  static bool get hasDraft => _draftStartAt != null;

  final FirebaseService _firebaseService = FirebaseService();
  late Future<(Plan?, List<Exercise>)> _dataFuture;

  Plan? _activePlan;
  List<Exercise> _exercises = [];
  String? _selectedDayKey;
  String? _selectedDayName;
  bool _isLoading = false;
  late Timer _timer;
  int _elapsedSeconds = 0;
  bool _isTimerRunning = false;

  final Map<String, List<WorkoutSet>> _workoutData = {};

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
    _draftStartAt ??= DateTime.now();
    _elapsedSeconds =
        DateTime.now().difference(_draftStartAt!).inSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    if (_isTimerRunning) {
      _timer.cancel();
    }
    super.dispose();
  }

  void _startTimer() {
    _isTimerRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
      _saveDraft();
    });
  }

  void _pauseTimer() {
    if (_isTimerRunning) {
      _timer.cancel();
      setState(() {
        _isTimerRunning = false;
      });
      _saveDraft();
    }
  }

  void _resumeTimer() {
    if (!_isTimerRunning) {
      _startTimer();
    }
  }

  void _resetTimer() {
    setState(() {
      _elapsedSeconds = 0;
    });
    _draftStartAt = DateTime.now();
    _saveDraft();
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<(Plan?, List<Exercise>)> _loadData() async {
    final activePlan = await _firebaseService.getActivePlan(widget.userId);
    final exercises = await _firebaseService.getExercises(widget.userId);
    return (activePlan, exercises);
  }

  String _getDayOfWeekKey() {
    final now = DateTime.now();
    const keys = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    return keys[now.weekday - 1];
  }

  String _getDayLabel(String dayKey, String dayName) {
    const dayLabels = {
      'monday': 'ponedeljak',
      'tuesday': 'utorak',
      'wednesday': 'sreda',
      'thursday': 'cetvrtak',
      'friday': 'petak',
      'saturday': 'subota',
      'sunday': 'nedelja',
    };
    final day = dayLabels[dayKey] ?? dayKey;
    return '$day - $dayName';
  }

  Map<String, List<WorkoutSet>> _cloneWorkoutData(
      Map<String, List<WorkoutSet>> source) {
    final cloned = <String, List<WorkoutSet>>{};
    for (var entry in source.entries) {
      cloned[entry.key] = List<WorkoutSet>.from(entry.value);
    }
    return cloned;
  }

  void _saveDraft() {
    if (_selectedDayKey == null || _selectedDayName == null) {
      return;
    }
    _draftDayKey = _selectedDayKey;
    _draftDayName = _selectedDayName;
    _draftWorkoutData = _cloneWorkoutData(_workoutData);
  }

  void _clearDraft() {
    _draftStartAt = null;
    _draftDayKey = null;
    _draftDayName = null;
    _draftWorkoutData = {};
  }

  void _initializeDayWorkouts(String dayKey) {
    if (_activePlan == null) return;
    final day = _activePlan!.days[dayKey];
    if (day == null) return;

    for (var exerciseId in day.exerciseIds) {
      _workoutData.putIfAbsent(
        exerciseId,
        () => List.generate(3, (_) => WorkoutSet(reps: 0, weight: 0.0)),
      );
    }
  }

  void _selectDay(String dayKey, String dayName) {
    setState(() {
      _selectedDayKey = dayKey;
      _selectedDayName = dayName;
      _initializeDayWorkouts(dayKey);
    });
    _saveDraft();
  }

  void _addSet(String exerciseId) {
    setState(() {
      _workoutData.putIfAbsent(exerciseId, () => []);
      _workoutData[exerciseId]!.add(WorkoutSet(reps: 0, weight: 0.0));
    });
    _saveDraft();
  }

  void _removeLastSet(String exerciseId) {
    setState(() {
      final sets = _workoutData[exerciseId];
      if (sets != null && sets.isNotEmpty) {
        sets.removeLast();
      }
    });
    _saveDraft();
  }

  void _updateSet(String exerciseId, int index, int reps, double weight) {
    setState(() {
      final sets = _workoutData[exerciseId];
      if (sets != null && index < sets.length) {
        sets[index] = WorkoutSet(reps: reps, weight: weight);
      }
    });
    _saveDraft();
  }

  Exercise? _findExerciseById(String exerciseId) {
    for (var exercise in _exercises) {
      if (exercise.id == exerciseId) {
        return exercise;
      }
    }
    return null;
  }

  double _getMaxWeight(List<WorkoutSet> sets) {
    double maxWeight = 0.0;
    for (var set in sets) {
      if (set.weight > maxWeight) {
        maxWeight = set.weight;
      }
    }
    return maxWeight;
  }

  Future<void> _saveWorkout() async {
    if (_selectedDayKey == null || _activePlan == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final exercises = <String, WorkoutExercise>{};

      final day = _activePlan!.days[_selectedDayKey];
      if (day != null) {
        for (var exerciseId in day.exerciseIds) {
          final sets = _workoutData[exerciseId] ?? [];
          final filteredSets = sets
              .where((set) => set.reps > 0 || set.weight > 0)
              .toList();
          if (filteredSets.isNotEmpty) {
            exercises[exerciseId] = WorkoutExercise(
              exerciseId: exerciseId,
              sets: filteredSets,
            );
          }
        }
      }

      if (exercises.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dodaj bar jedan set pre cuvanja.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final workout = Workout(
        id: '', 
        userId: widget.userId,
        planId: _activePlan!.id,
        dayName: _selectedDayName ?? 'Dan',
        date: DateTime.now(),
        exercises: exercises,
        durationSeconds: _elapsedSeconds,
      );

      await _firebaseService.saveWorkout(widget.userId, workout);

      final now = DateTime.now();
      for (var entry in exercises.entries) {
        final exerciseId = entry.key;
        final sets = entry.value.sets;
        final maxWeight = _getMaxWeight(sets);
        final exercise = _findExerciseById(exerciseId);

        double? newPr;
        if (maxWeight > 0 &&
            (exercise == null ||
                exercise.personalRecord == null ||
                maxWeight > exercise.personalRecord!)) {
          newPr = maxWeight;
        }

        await _firebaseService.updateExercise(
          widget.userId,
          exerciseId,
          personalRecord: newPr,
          lastDone: now,
          incrementWorkoutCount: true,
        );
      }

      if (!mounted) return;
      _clearDraft();
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trening uspešno sačuvan!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Otkaži trening'),
        content: const Text(
            'Da li si siguran? Svi uneti podaci će biti obrisani.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nastavi'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              _clearDraft();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Otkaži'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(Plan?, List<Exercise>)>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Greška'),
              backgroundColor: const Color(0xFF808080),
            ),
            body: Center(
              child: Text('Greška pri preuzimanju podataka: ${snapshot.error}'),
            ),
          );
        }

        final (activePlan, exercises) =
            snapshot.data ?? (null, <Exercise>[]);

        if (activePlan == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Započni trening'),
              backgroundColor: const Color(0xFF808080),
            ),
            body: const Center(
              child: Text('Nema aktivnog plana. Postavi plan kao aktivan.'),
            ),
          );
        }

        _activePlan = activePlan;
        _exercises = exercises;

        if (_selectedDayKey == null && _draftDayKey != null) {
          _selectedDayKey = _draftDayKey;
          _selectedDayName =
              _draftDayName ?? activePlan.days[_draftDayKey!]?.name ?? 'Dan';
          _workoutData
            ..clear()
            ..addAll(_cloneWorkoutData(_draftWorkoutData));
        }

        // Odredi koji je dan u nedelji
        final todayDayKey = _getDayOfWeekKey();
        if (_selectedDayKey == null && activePlan.days.containsKey(todayDayKey)) {
          _selectedDayKey = todayDayKey;
          _selectedDayName =
              activePlan.days[todayDayKey]?.name ?? 'Dan';
          _initializeDayWorkouts(todayDayKey);
          _saveDraft();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Započni trening'),
            backgroundColor: const Color(0xFF808080),
            actions: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    _formatTime(_elapsedSeconds),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                color: Colors.grey[100],
                child: Row(
                  children: [
                    Text(
                      _formatTime(_elapsedSeconds),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: _isTimerRunning ? 'Pauza' : 'Nastavi',
                      icon: Icon(
                        _isTimerRunning ? Icons.pause : Icons.play_arrow,
                      ),
                      onPressed:
                          _isTimerRunning ? _pauseTimer : _resumeTimer,
                    ),
                    IconButton(
                      tooltip: 'Reset',
                      icon: const Icon(Icons.restart_alt),
                      onPressed: _resetTimer,
                    ),
                  ],
                ),
              ),
              
              Container(
                color: Colors.grey[200],
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: activePlan.days.entries.map((entry) {
                      final dayKey = entry.key;
                      final day = entry.value;
                      final isSelected = _selectedDayKey == dayKey;
                      final isToday = dayKey == todayDayKey;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FilterChip(
                            label: Text(_getDayLabel(dayKey, day.name)),
                            selected: isSelected,
                            onSelected: (_) => _selectDay(dayKey, day.name),
                            backgroundColor: isToday
                                ? Colors.blue[100]
                                : Colors.white,
                            selectedColor: Colors.blue,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              // Vežbe za izabrani dan
              if (_selectedDayKey != null)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount:
                        activePlan.days[_selectedDayKey]?.exerciseIds.length ??
                            0,
                    itemBuilder: (context, index) {
                      final exerciseId =
                          activePlan.days[_selectedDayKey]!.exerciseIds[index];
                        final exercise = _findExerciseById(exerciseId);
                        final exerciseName =
                          exercise?.name ?? 'Nepoznata vezba';
                      final sets = _workoutData[exerciseId] ?? [];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        child: ExpansionTile(
                          title: Text(exerciseName),
                          subtitle: Text(
                            sets.isEmpty
                                ? 'Dodaj setove'
                                : '${sets.length} setova',
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: sets.length,
                                    itemBuilder: (context, setIndex) {
                                      final set = sets[setIndex];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  hintText: 'Ponavljanja',
                                                  border:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                onChanged: (value) {
                                                  final reps =
                                                      int.tryParse(value) ?? 0;
                                                  _updateSet(exerciseId,
                                                      setIndex, reps, set.weight);
                                                },
                                                controller: TextEditingController(
                                                  text: set.reps > 0
                                                      ? set.reps.toString()
                                                      : '',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: TextField(
                                                keyboardType:
                                                    const TextInputType
                                                        .numberWithOptions(
                                                        decimal: true),
                                                decoration: InputDecoration(
                                                  hintText: 'kg',
                                                  border:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                onChanged: (value) {
                                                  final weight =
                                                      double.tryParse(value) ??
                                                          0.0;
                                                  _updateSet(
                                                      exerciseId,
                                                      setIndex,
                                                      set.reps,
                                                      weight);
                                                },
                                                controller: TextEditingController(
                                                  text: set.weight > 0
                                                      ? set.weight.toString()
                                                      : '',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF808080),
                                          ),
                                          onPressed: () => _addSet(exerciseId),
                                          icon: const Icon(Icons.add),
                                          label: const Text('Dodaj set'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: sets.isNotEmpty
                                              ? () => _removeLastSet(exerciseId)
                                              : null,
                                          icon: const Icon(Icons.remove),
                                          label: const Text('Smanji set'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else
                const Expanded(
                  child: Center(
                    child: Text('Izaberi dan da počneš'),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _showCancelDialog,
                    child: const Text('Otkaži trening'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF808080),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _isLoading ? null : _saveWorkout,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                        : const Text('Završi trening'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
