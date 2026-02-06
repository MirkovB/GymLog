import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planovi'),
        backgroundColor: const Color(0xFF808080),
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text('Planovi vežbanja'),
      ),
    );
  }
}
