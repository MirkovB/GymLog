import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF808080), Color(0xFF606060)],
                  ),
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
                    const SizedBox(height: 12),
                    Text(
                      user?.displayName ?? user?.email ?? 'GymLog',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (user != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: user.role == UserRole.admin
                                  ? Colors.red[700]
                                  : Colors.green[700],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user.role == UserRole.admin
                                  ? 'ADMIN'
                                  : 'KORISNIK',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Glavni meni
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Početna'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/home');
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
                leading: const Icon(Icons.wb_sunny),
                title: const Text('Vreme'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/weather');
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

              // Admin panel - samo za admin korisnike
              if (user != null && user.role == UserRole.admin)
                ...<Widget>[
                const Divider(),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: const Text(
                    'ADMIN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
                  title: const Text('Admin Panel'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/admin');
                  },
                ),
              ],

              const Divider(),

              // Odjava
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Odjavi se'),
                onTap: () async {
                  Navigator.pop(context);
                  await userProvider.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
