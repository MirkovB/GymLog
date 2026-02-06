import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF808080),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.fitness_center,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  'GymLog',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Početna'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Planovi'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/plans');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Treninzi'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/sessions');
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Vežbe'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/exercises');
            },
          ),
          ListTile(
            leading: const Icon(Icons.monitor_weight),
            title: const Text('Telesne Mere'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/body-metrics');
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Statistika'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/stats');
            },
          ),
        ],
      ),
    );
  }
}
