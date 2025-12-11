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

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        title: const Text(
          "Panel Administrador",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        centerTitle: false,
      ),

      body: views[currentIndex],

      bottomNavigationBar: AdminNavBar(
        currentIndex: currentIndex,
        onChange: (i) => setState(() => currentIndex = i),
        onLogout: () {
          auth.logout();
          Navigator.pushReplacementNamed(context, "/");
        },
      ),
    );
  }
}

