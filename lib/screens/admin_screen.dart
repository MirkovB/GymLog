import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'admin_users_screen.dart';
import 'admin_plans_screen.dart';
import 'admin_exercises_screen.dart';
import 'admin_stats_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  final List<AdminTab> _tabs = [
    AdminTab(
      label: 'Korisnici',
      icon: Icons.people,
      screen: const AdminUsersScreen(),
    ),
    AdminTab(
      label: 'Planovi',
      icon: Icons.assignment,
      screen: const AdminPlansScreen(),
    ),
    AdminTab(
      label: 'Vežbe',
      icon: Icons.fitness_center,
      screen: const AdminExercisesScreen(),
    ),
    AdminTab(
      label: 'Statistika',
      icon: Icons.bar_chart,
      screen: const AdminStatsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        title: const Text('Admin Panel'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  return Text(
                    userProvider.user?.displayName ?? 'Admin',
                    style: const TextStyle(fontSize: 16),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: _tabs[_selectedIndex].screen,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: _tabs
            .map(
              (tab) => BottomNavigationBarItem(
                icon: Icon(tab.icon),
                label: tab.label,
              ),
            )
            .toList(),
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}

class AdminTab {
  final String label;
  final IconData icon;
  final Widget screen;

  AdminTab({
    required this.label,
    required this.icon,
    required this.screen,
  });
}

