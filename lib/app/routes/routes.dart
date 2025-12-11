import 'package:flutter/material.dart';
import '../../ui/screens/screens.dart';

class AppRouter {
  static const String initialRoute = '/';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // --- LOGIN ---
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      // --- DASHBOARD ADMIN ---
      case '/admin':
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());

      // --- RUTA NO ENCONTRADA ---
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                "Ruta no encontrada: ${settings.name}",
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        );
    }
  }
}
