import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class BodyMetricsScreen extends StatelessWidget {
  const BodyMetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telesne Mere'),
        backgroundColor: const Color(0xFF808080),
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text('Praćenje težine i mera'),
      ),
    );
  }
}
