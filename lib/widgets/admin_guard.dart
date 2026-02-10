import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';

class AdminGuard extends StatelessWidget {
  final Widget child;

  const AdminGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (userProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF808080),
              ),
            ),
          );
        }

        if (!userProvider.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF808080),
              ),
            ),
          );
        }

        if (userProvider.user?.role != UserRole.admin) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/home');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Nemate pristup admin panelu.'),
                backgroundColor: Colors.red,
              ),
            );
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF808080),
              ),
            ),
          );
        }

        return child;
      },
    );
  }
}

class AdminRoute extends StatelessWidget {
  final WidgetBuilder builder;

  const AdminRoute({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return AdminGuard(child: builder(context));
  }
}
