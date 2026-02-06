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
      body: const Center(
        child: Text('Statistika i grafici'),
      ),
    );
  }
}
