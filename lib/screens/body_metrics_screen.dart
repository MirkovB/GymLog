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
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.monitor_weight,
                    size: 48,
                    color: Color(0xFF808080),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trenutna težina',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '75.5 kg',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF808080),
                              ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Unesi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF808080),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  'Istorija merenja',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: 10,
              itemBuilder: (context, index) {
                final weight = 75.5 - (index * 0.2);
                final date = DateTime.now().subtract(Duration(days: index * 7));
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF808080),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text('${weight.toStringAsFixed(1)} kg'),
                    subtitle: Text('${date.day}.${date.month}.${date.year}'),
                    trailing: index == 0
                        ? const Chip(
                            label: Text('Najnovije', style: TextStyle(fontSize: 11)),
                            backgroundColor: Color(0xFF90EE90),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF808080),
        child: const Icon(Icons.add),
      ),
    );
  }
}
