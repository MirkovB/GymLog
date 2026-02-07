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
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 10,
        itemBuilder: (context, index) {
          final date = DateTime.now().subtract(Duration(days: index));
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF808080),
                child: const Icon(Icons.fitness_center, color: Colors.white),
              ),
              title: Text('Trening ${index + 1}'),
              subtitle: Text(
                '${date.day}.${date.month}.${date.year} • ${40 + index * 5} min',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF808080),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Započni trening'),
      ),
    );
  }
}
