import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/plans_screen.dart';
import 'screens/sessions_screen.dart';
import 'screens/exercises_screen.dart';
import 'screens/body_metrics_screen.dart';
import 'screens/stats_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymLog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/plans': (context) => const PlansScreen(),
        '/sessions': (context) => const SessionsScreen(),
        '/exercises': (context) => const ExercisesScreen(),
        '/body-metrics': (context) => const BodyMetricsScreen(),
        '/stats': (context) => const StatsScreen(),
      },
    );
  }
}
