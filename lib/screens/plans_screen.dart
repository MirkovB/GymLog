import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../models/plan.dart';
import '../services/firebase_service.dart';
import '../providers/user_provider.dart';
import 'plan_detail_screen.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<Plan>> _plansFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.id ?? 'demo-user';
    _plansFuture = _firebaseService.getPlans(userId);
  }

  void _refreshPlans() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.id ?? 'demo-user';
    setState(() {
      _plansFuture = _firebaseService.getPlans(userId);
    });
  }

  void _showAddPlanDialog() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.id ?? '';
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dodaj novi plan'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Naziv plana (npr. PPL Split)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF808080),
            ),
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                try {
                  await _firebaseService.addPlan(userId, controller.text);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _refreshPlans();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Plan uspešno dodat!')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Greška: $e')),
                  );
                }
              }
            },
            child: const Text('Dodaj'),
          ),
        ],
      ),
    );
  }

  void _showEditPlanDialog(Plan plan) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.id ?? '';
    final TextEditingController controller =
        TextEditingController(text: plan.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izmeni plan'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Naziv plana',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF808080),
            ),
            onPressed: () async {
              if (controller.text.isNotEmpty &&
                  controller.text != plan.title) {
                try {
                  await _firebaseService.updatePlan(
                      userId, plan.id, controller.text);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _refreshPlans();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Plan uspešno izmenjen!')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Greška: $e')),
                  );
                }
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('Sačuvaj'),
          ),
        ],
      ),
    );
  }

  void _deletePlan(String planId) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.id ?? '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Brisanje plana'),
        content: const Text('Da li ste sigurni da želite da obrišete ovaj plan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ne'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              try {
                await _firebaseService.deletePlan(userId, planId);
                if (!context.mounted) return;
                Navigator.pop(context);
                _refreshPlans();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Plan uspešno obrisan!')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Greška: $e')),
                );
              }
            },
            child: const Text('Obriši'),
          ),
        ],
      ),
    );
  }

  void _toggleActivePlan(Plan plan) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.id ?? '';
    
    try {
      if (plan.isActive) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ovaj plan je već aktivan')),
        );
        return;
      }

      await _firebaseService.setActivePlan(userId, plan.id);
      _refreshPlans();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${plan.title} postavljen kao aktivan plan!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: $e')),
      );
    }
  }

  int _getTotalExercises(Plan plan) {
    int total = 0;
    for (var day in plan.days.values) {
      total += day.exerciseIds.length;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isGuest = userProvider.user == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isGuest ? 'Planovi (Pregled)' : 'Planovi'),
        backgroundColor: const Color(0xFF808080),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          if (isGuest)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange[100],
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Prijavite se da biste kreirali svoje planove',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pretraži planove...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Plan>>(
              future: _plansFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Greška: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF808080),
                          ),
                          onPressed: _refreshPlans,
                          child: const Text('Pokušaj ponovo'),
                        ),
                      ],
                    ),
                  );
                }

                final plans = snapshot.data ?? [];
                final filteredPlans = plans
                    .where((plan) =>
                        plan.title.toLowerCase().contains(_searchQuery))
                    .toList();

                if (filteredPlans.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(_searchQuery.isEmpty
                            ? 'Nema planova. Dodaj novi!'
                            : 'Nema rezultata pretrage'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: filteredPlans.length,
                  itemBuilder: (context, index) {
                    final plan = filteredPlans[index];
                    final totalExercises = _getTotalExercises(plan);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      elevation: plan.isActive ? 4 : 1,
                      color: plan.isActive
                          ? const Color(0xFFE8E8E8)
                          : Colors.white,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: plan.isActive
                              ? Colors.green
                              : const Color(0xFF808080),
                          child: Icon(
                            plan.isActive
                                ? Icons.check_circle
                                : Icons.calendar_today,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text(plan.title)),
                            if (plan.isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'AKTIVNO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          '${plan.days.length} dana • $totalExercises vežbi',
                          style: const TextStyle(fontSize: 13),
                        ),
                        trailing: PopupMenuButton(
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                _showEditPlanDialog(plan);
                                break;
                              case 'activate':
                                _toggleActivePlan(plan);
                                break;
                              case 'delete':
                                _deletePlan(plan.id);
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text('Izmeni'),
                                ],
                              ),
                            ),
                            if (!plan.isActive)
                              const PopupMenuItem(
                                value: 'activate',
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, size: 18),
                                    SizedBox(width: 8),
                                    Text('Postavi aktivnim'),
                                  ],
                                ),
                              ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Obriši',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          final userProvider = Provider.of<UserProvider>(context, listen: false);
                          final userId = userProvider.user?.id ?? '';
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlanDetailScreen(
                                plan: plan,
                                userId: userId,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isGuest
          ? null
          : FloatingActionButton(
              onPressed: _showAddPlanDialog,
              backgroundColor: const Color(0xFF808080),
              child: const Icon(Icons.add),
            ),
    );
  }
}
