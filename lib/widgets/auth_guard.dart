import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

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

        return child;
      },
    );
  }
}

class AuthenticatedRoute extends StatelessWidget {
  final WidgetBuilder builder;

  const AuthenticatedRoute({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return AuthGuard(child: builder(context));
  }
}
