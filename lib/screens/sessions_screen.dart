import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treninzi'),
        backgroundColor: const Color(0xFF808080),
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text('Istorija treninga'),
      ),
    );
  }
}
