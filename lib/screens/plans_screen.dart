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
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF808080),
                child: Text('${index + 1}'),
              ),
              title: Text('Plan treninga ${index + 1}'),
              subtitle: Text('7 dana • ${(index + 1) * 3} vežbi'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF808080),
        child: const Icon(Icons.add),
      ),
    );
  }
}
