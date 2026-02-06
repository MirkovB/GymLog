import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vežbe'),
        backgroundColor: const Color(0xFF808080),
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text('Lista vežbi'),
      ),
    );
  }
}
