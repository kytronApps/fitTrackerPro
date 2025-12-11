import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/colors.dart';
import '../../../providers/auth_provider.dart';

// Barriles de widgets y vistas
import '../../widgets/widgets.dart';
import '../../views/views.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int currentIndex = 0;

  // Las vistas internas que cambian según el menú seleccionado
  final List<Widget> views = const [
    AdminUsersView(),
    AdminWeeklyView(),
    AdminMetricsView(),
    AdminMenusView(),
    AdminCalculatorView(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 🔵 HEADER
          AdminTopBar(
            onLogout: () => auth.logout(),
          ),

          // 🔵 NAVBAR
          AdminNavBar(
            currentIndex: currentIndex,
            onChange: (i) => setState(() => currentIndex = i),
          ),

          // 🔵 CONTENIDO CAMBIANTE
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: Padding(
                key: ValueKey(currentIndex),
                padding: const EdgeInsets.all(16),
                child: views[currentIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
