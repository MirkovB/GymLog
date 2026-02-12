import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/user_provider.dart';
import 'widgets/auth_wrapper.dart';
import 'widgets/auth_guard.dart';
import 'widgets/admin_guard.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/guest_home_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/plans_screen.dart';
import 'screens/sessions_screen.dart';
import 'screens/exercises_screen.dart';
import 'screens/body_metrics_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/weather_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MaterialApp(
        title: 'GymLog',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F5F9),
          useMaterial3: true,
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/guest-home': (context) => const GuestHomeScreen(),
          // Zaštićene rute - pristup samo za ulogovane korisnike
          '/home': (context) =>
              AuthenticatedRoute(builder: (_) => const HomeScreen()),
          '/plans': (context) => const PlansScreen(), // Gost može videti
          '/sessions': (context) => const SessionsScreen(), // Gost može videti
          '/exercises': (context) =>
              const ExercisesScreen(), // Gost može videti
          '/body-metrics': (context) =>
              AuthenticatedRoute(builder: (_) => const BodyMetricsScreen()),
          '/weather': (context) => const WeatherScreen(), // Gost može videti
          '/stats': (context) => const StatsScreen(), // Gost može videti
          // Admin rute - pristup samo za admin korisnike
          '/admin': (context) =>
              AdminRoute(builder: (_) => const AdminScreen()),
        },
      ),
    );
  }
}
